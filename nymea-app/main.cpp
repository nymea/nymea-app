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

#include "stylecontroller.h"
#include "pushnotifications.h"
#include "ruletemplates/messages.h"
#include "nfchelper.h"
#include "nfcthingactionwriter.h"
#include "platformhelper.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcApplication, "Application")
NYMEA_LOGGING_CATEGORY(qml, "qml")

int main(int argc, char *argv[])
{

#ifdef Q_OS_OSX
    qputenv("QT_WEBVIEW_PLUGIN", "native");
#endif

    // qt.qml.connections warnings are disabled since the replace only exists
    // in Qt 5.12. Remove that once 5.12 is the minimum supported version.
    QLoggingCategory::setFilterRules("RemoteProxyClientJsonRpcTraffic.debug=false\n"
                                     "RemoteProxyClientJsonRpc.debug=false\n"
                                     "RemoteProxyClientWebSocket.debug=false\n"
                                     "RemoteProxyClientConnection.debug=false\n"
                                     "RemoteProxyClientConnectionTraffic.debug=false\n"
                                     "qt.qml.connections.warning=false\n"
                                     );
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication application(argc, argv);

    QSettings config(":/config.txt", QSettings::IniFormat);
    application.setApplicationName(config.value("app").toString());
    application.setOrganizationName(config.value("organisation").toString());

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

    // Initialize app log controller as early as possible, but after setting app name etc
    AppLogController::instance();

    QTranslator qtTranslator;    
    qtTranslator.load("qt_" + QLocale::system().name(), QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    application.installTranslator(&qtTranslator);

    qCInfo(dcApplication()) << application.applicationName() << APP_VERSION << "running on" << QSysInfo::machineHostName() << QSysInfo::prettyProductName() << QSysInfo::productType() << QSysInfo::productVersion();
    qCInfo(dcApplication()) << "Locale info:" << QLocale() << QLocale().name() << QLocale().language() << QLocale().system();

    QTranslator appTranslator;
    bool translationResult = appTranslator.load("nymea-app-" + QLocale().name(), ":/translations/");
    if (translationResult) {
        qCDebug(dcApplication()) << "Loaded translation for locale" << QLocale();
    } else {
        qCInfo(dcApplication()) << "Failed to load translations for locale" << QLocale();
    }
    application.installTranslator(&appTranslator);

    registerQmlTypes();

    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

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
    qmlRegisterSingletonType(QUrl("qrc:///ui/Configuration.qml"), "Nymea", 1, 0, "Configuration");

    engine->rootContext()->setContextProperty("styleController", &styleController);

    qmlRegisterSingletonType<PlatformHelper>("Nymea", 1, 0, "PlatformHelper", PlatformHelper::platformHelperProvider);
    qmlRegisterSingletonType<NfcHelper>("Nymea", 1, 0, "NfcHelper", NfcHelper::nfcHelperProvider);
    qmlRegisterType<NfcThingActionWriter>("Nymea", 1, 0, "NfcThingActionWriter");

    qmlRegisterSingletonType<PushNotifications>("Nymea", 1, 0, "PushNotifications", PushNotifications::pushNotificationsProvider);
    qmlRegisterSingletonType(QUrl("qrc:///ui/utils/NymeaUtils.qml"), "Nymea", 1, 0, "NymeaUtils" );

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
