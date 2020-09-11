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

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras/QtAndroid>
#include "platformintegration/android/platformhelperandroid.h"
#elif defined(Q_OS_IOS)
#include "platformintegration/ios/platformhelperios.h"
#else
#include "platformintegration/generic/platformhelpergeneric.h"
#endif

#include "libnymea-app-core.h"

#include "stylecontroller.h"
#include "pushnotifications.h"
#include "applogcontroller.h"
#include "ruletemplates/messages.h"

QObject *platformHelperProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
#ifdef Q_OS_ANDROID
    return new PlatformHelperAndroid();
#elif defined(Q_OS_IOS)
    return new PlatformHelperIOS();
#else
    return new PlatformHelperGeneric();
#endif
}


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
    application.setApplicationName("nymea-app");
    application.setOrganizationName("nymea");

    QCommandLineParser parser;
    parser.addHelpOption();
    QCommandLineOption kioskOption = QCommandLineOption({"k", "kiosk"}, "Start the application in kiosk mode.");
    parser.addOption(kioskOption);
    QCommandLineOption connectOption = QCommandLineOption({"c", "connect"}, "Connect to nymea:core without discovery.", "host");
    parser.addOption(connectOption);
    parser.process(application);

    // Initialize app log controller as early as possible, but after setting app name etc
    AppLogController::instance();

    foreach (const QFileInfo &fi, QDir(":/ui/fonts/").entryInfoList()) {
        QFontDatabase::addApplicationFont(fi.absoluteFilePath());
    }

    QTranslator qtTranslator;    
    qtTranslator.load("qt_" + QLocale::system().name(),
            QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    application.installTranslator(&qtTranslator);

    qDebug() << "nymea:app" << APP_VERSION << "running on" << QSysInfo::machineHostName() << QSysInfo::prettyProductName() << QSysInfo::productType() << QSysInfo::productVersion();
    qDebug() << "Locale info:" << QLocale() << QLocale().name() << QLocale().language() << QLocale().system();

    QTranslator appTranslator;
    bool translationResult = appTranslator.load(QLocale(), "nymea-app", "-", ":/translations/", ".qm");
    if (translationResult) {
        qDebug() << "Loaded translation for locale" << QLocale();
    } else {
        qWarning() << "Failed to load translations for locale" << QLocale();
    }
    application.installTranslator(&appTranslator);

    registerQmlTypes();

    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    qmlRegisterSingletonType<PlatformHelper>("Nymea", 1, 0, "PlatformHelper", platformHelperProvider);

    PushNotifications::instance()->connectClient();
    qmlRegisterSingletonType<PushNotifications>("Nymea", 1, 0, "PushNotifications", PushNotifications::pushNotificationsProvider);
    qmlRegisterSingletonType<AppLogController>("Nymea", 1, 0, "AppLogController", AppLogController::appLogControllerProvider);
    qmlRegisterSingletonType(QUrl("qrc:///ui/utils/NymeaUtils.qml"), "Nymea", 1, 0, "NymeaUtils" );

#ifdef BRANDING
    engine->rootContext()->setContextProperty("appBranding", BRANDING);
#else
    engine->rootContext()->setContextProperty("appBranding", "");
#endif
    engine->rootContext()->setContextProperty("appVersion", APP_VERSION);
    engine->rootContext()->setContextProperty("qtBuildVersion", QT_VERSION_STR);
    engine->rootContext()->setContextProperty("qtVersion", qVersion());

    StyleController styleController;
    engine->rootContext()->setContextProperty("styleController", &styleController);

    engine->rootContext()->setContextProperty("kioskMode", parser.isSet(kioskOption));
    engine->rootContext()->setContextProperty("autoConnectHost", parser.value(connectOption));

    engine->rootContext()->setContextProperty("systemProductType", QSysInfo::productType());

    engine->rootContext()->setContextProperty("useVirtualKeyboard", qgetenv("QT_IM_MODULE") == "qtvirtualkeyboard");

    application.setWindowIcon(QIcon(QString(":/styles/%1/logo.svg").arg(styleController.currentStyle())));

    engine->load(QUrl(QLatin1String("qrc:/ui/Nymea.qml")));

    return application.exec();
}
