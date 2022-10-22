/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <QApplication>
#include <QCommandLineParser>
#include <QtQml/QQmlContext>
#include <QQmlApplicationEngine>
#include <QtQuickControls2>
#include <QSysInfo>
#include <QCommandLineParser>
#include <QCommandLineOption>

#include "libnymea-app-core.h"
#include "libnymea-app-airconditioning.h"

#include "stylecontroller.h"
#include "pushnotifications.h"
#include "ruletemplates/messages.h"
#include "nfchelper.h"
#include "nfcthingactionwriter.h"
#include "platformhelper.h"
#include "platformintegration/platformpermissions.h"
#include "dashboard/dashboardmodel.h"
#include "dashboard/dashboarditem.h"
#include "mouseobserver.h"
#include "configuredhostsmodel.h"
#include "../config.h"

#include "logging.h"

#ifdef OVERLAY_QMLTYPES
#include OVERLAY_QMLTYPES
#endif

NYMEA_LOGGING_CATEGORY(dcApplication, "Application")
NYMEA_LOGGING_CATEGORY(qml, "qml")

int main(int argc, char *argv[])
{

#ifdef Q_OS_OSX
    qputenv("QT_WEBVIEW_PLUGIN", "native");
#endif

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication application(argc, argv);

    application.setApplicationName(APPLICATION_NAME);
    application.setOrganizationName(ORGANISATION_NAME);

    QCommandLineParser parser;
    parser.addHelpOption();
    QCommandLineOption connectOption = QCommandLineOption({"c", "connect"}, "Connect to nymea:core without discovery.", "host");
    parser.addOption(connectOption);
    QCommandLineOption styleOption = QCommandLineOption({"s", "style"}, "Override the style. Style in settings will be disabled.", "style");
    parser.addOption(styleOption);
    QCommandLineOption defaultStyleOption = QCommandLineOption({"d", "default-style"}, "The default style to be used if there is no style explicitly selected by the user yet.", "style");
    parser.addOption(defaultStyleOption);
    QCommandLineOption defaultViewsOption = QCommandLineOption({"v", "default-views"}, "The main views enabled by default if there is no configuration done by the user and the style doesn't dictate them, comma separated.", "mainviews");
    parser.addOption(defaultViewsOption);
    QCommandLineOption kioskOption = QCommandLineOption({"k", "kiosk"}, "Start the application in kiosk mode.");
    parser.addOption(kioskOption);
    QCommandLineOption splashOption = QCommandLineOption({"p", "splash"}, "Show a splash screen on startup.");
    parser.addOption(splashOption);
    parser.process(application);

    // Initialize app log controller as early as possible, but after setting app name and printing initial startup info
    AppLogController::instance();

    qCInfo(dcApplication()) << "-->" << application.applicationName() << APP_VERSION << QDateTime::currentDateTime().toString();
    qCInfo(dcApplication()) << "Command line:" << application.arguments().join(" ");
    qCInfo(dcApplication()) << "System:" << QSysInfo::machineHostName() << QSysInfo::prettyProductName() << QSysInfo::productType() << QSysInfo::productVersion() << PlatformHelper::instance()->deviceManufacturer() << PlatformHelper::instance()->deviceModel();
    qCInfo(dcApplication()) << "Locale:" << QLocale() << QLocale().name() << QLocale().language();

    foreach (const QString &argument, application.arguments()) {
        if (argument.startsWith("nymea://notification")) {
            PlatformHelper::instance()->notificationActionReceived(QUrlQuery(QUrl(argument).query()).queryItemValue("nymeaData"));
        }
    }

    QTranslator qtTranslator;    
    qtTranslator.load("qt_" + QLocale::system().name(), QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    application.installTranslator(&qtTranslator);


    QTranslator appTranslator;
    bool translationResult = appTranslator.load("nymea-app-" + QLocale().name(), ":/translations/");
    if (translationResult) {
        qCDebug(dcApplication()) << "Loaded translation for locale" << QLocale();
    } else {
        qCInfo(dcApplication()) << "Failed to load translations for locale" << QLocale();
    }
    application.installTranslator(&appTranslator);

#ifdef OVERLAY_PATH
    QTranslator overlayTranslator;
    translationResult = overlayTranslator.load(QString("%1-%2").arg(APPLICATION_NAME).arg(QLocale().name()), ":/translations");
    if (translationResult) {
        qCDebug(dcApplication()) << "Loaded overlay translation for locale" << QString("%1-%2").arg(APPLICATION_NAME).arg(QLocale().name());
    } else {
        qCInfo(dcApplication()) << "Failed to load overlay translations for locale" << QString("%1-%2").arg(APPLICATION_NAME).arg(QLocale().name());
    }
    application.installTranslator(&overlayTranslator);
#endif

    Nymea::Core::registerQmlTypes();
    Nymea::AirConditioning::registerQmlTypes();

    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    engine->addImportPath(application.applicationDirPath() + "/../experiences/");

    QString defaultStyle;
    if (parser.isSet(defaultStyleOption)) {
        defaultStyle = parser.value(defaultStyleOption);
    } else if (PlatformHelper::instance()->darkModeEnabled()) {
        defaultStyle = "dark";
    } else {
        defaultStyle = "light";
    }
    StyleController styleController(defaultStyle);
    if (parser.isSet(styleOption)) {
        qCInfo(dcApplication()) << "Setting style to" << defaultStyle;
        styleController.lockToStyle(parser.value(styleOption));
    }

    QQmlFileSelector *styleSelector = new QQmlFileSelector(engine);
    styleSelector->setExtraSelectors({styleController.currentStyle()});

    foreach (const QFileInfo &fi, QDir(":/ui/fonts/").entryInfoList()) {
        QFontDatabase::addApplicationFont(fi.absoluteFilePath());
    }
    foreach (const QFileInfo &fi, QDir(":/styles/" + styleController.currentStyle() + "/fonts/").entryInfoList()) {
        qCDebug(dcApplication()) << "Adding style font:" << fi.absoluteFilePath();
        QFontDatabase::addApplicationFont(fi.absoluteFilePath());
    }

    qmlRegisterSingletonType(QUrl("qrc:///styles/" + styleController.currentStyle() + "/Style.qml"), "Nymea", 1, 0, "Style" );
    qmlRegisterType(QUrl("qrc:///styles/" + styleController.currentStyle() + "/Background.qml"), "Nymea", 1, 0, "Background" );
    qmlRegisterSingletonType(QUrl("qrc:///ui/Configuration.qml"), "Nymea", 1, 0, "Configuration");

    engine->rootContext()->setContextProperty("styleController", &styleController);

    qmlRegisterSingletonType<PlatformHelper>("Nymea", 1, 0, "PlatformHelper", PlatformHelper::platformHelperProvider);
    qmlRegisterSingletonType<PlatformPermissions>("Nymea", 1, 0, "PlatformPermissions", PlatformPermissions::qmlProvider);
    qmlRegisterSingletonType<NfcHelper>("Nymea", 1, 0, "NfcHelper", NfcHelper::nfcHelperProvider);
    qmlRegisterType<NfcThingActionWriter>("Nymea", 1, 0, "NfcThingActionWriter");

    qmlRegisterSingletonType<PushNotifications>("Nymea", 1, 0, "PushNotifications", PushNotifications::pushNotificationsProvider);
    qmlRegisterSingletonType(QUrl("qrc:///ui/utils/NymeaUtils.qml"), "NymeaApp.Utils", 1, 0, "NymeaUtils" );
    qmlRegisterSingletonType(QUrl("qrc:///ui/utils/AirQualityIndex.qml"), "NymeaApp.Utils", 1, 0, "AirQualityIndex" );

    qmlRegisterType<DashboardModel>("Nymea", 1, 0, "DashboardModel");
    qmlRegisterUncreatableType<DashboardItem>("Nymea", 1, 0, "DashboardItem", "");
    qmlRegisterUncreatableType<DashboardThingItem>("Nymea", 1, 0, "DashboardThingItem", "");
    qmlRegisterUncreatableType<DashboardFolderItem>("Nymea", 1, 0, "DashboardFolderItem", "");
    qmlRegisterUncreatableType<DashboardGraphItem>("Nymea", 1, 0, "DashboardGraphItem", "");
    qmlRegisterUncreatableType<DashboardSceneItem>("Nymea", 1, 0, "DashboardSceneItem", "");
    qmlRegisterUncreatableType<DashboardWebViewItem>("Nymea", 1, 0, "DashboardWebViewItem", "");

    qmlRegisterType<MouseObserver>("Nymea", 1, 0, "MouseObserver");

    qmlRegisterType<ConfiguredHostsModel>("Nymea", 1, 0, "ConfiguredHostsModel");
    qmlRegisterType<ConfiguredHostsProxyModel>("Nymea", 1, 0, "ConfiguredHostsProxyModel");
    qmlRegisterUncreatableType<ConfiguredHost>("Nymea", 1, 0, "ConfiguredHost", "Get them from ConfiguredHostsModel");

#ifdef OVERLAY_PATH
    registerOverlayTypes("Nymea", 1, 0);
#endif

    engine->rootContext()->setContextProperty("appVersion", APP_VERSION);
    engine->rootContext()->setContextProperty("qtBuildVersion", QT_VERSION_STR);
    engine->rootContext()->setContextProperty("qtVersion", qVersion());

    engine->rootContext()->setContextProperty("defaultMainViewFilter", parser.value(defaultViewsOption));
    engine->rootContext()->setContextProperty("kioskMode", parser.isSet(kioskOption));
    engine->rootContext()->setContextProperty("showSplash", parser.isSet(splashOption));
    engine->rootContext()->setContextProperty("autoConnectHost", parser.value(connectOption));

    engine->rootContext()->setContextProperty("systemProductType", QSysInfo::productType());

    engine->rootContext()->setContextProperty("useVirtualKeyboard", qgetenv("QT_IM_MODULE") == "qtvirtualkeyboard");

    application.setWindowIcon(QIcon(QString(":/styles/%1/logo.svg").arg(styleController.currentStyle())));

    engine->load(QUrl(QLatin1String("qrc:/ui/Nymea.qml")));

    return application.exec();
}
