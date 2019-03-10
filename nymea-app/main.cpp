/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app.                                      *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <QApplication>
#include <QCommandLineParser>
#include <QtQml/QQmlContext>
#include <QQmlApplicationEngine>
#include <QtQuickControls2>
#include <QSysInfo>

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

    QLoggingCategory::setFilterRules("RemoteProxyClientJsonRpcTraffic.debug=false\n"
                                     "RemoteProxyClientJsonRpc.debug=false\n"
                                     "RemoteProxyClientWebSocket.debug=false\n"
                                     "RemoteProxyClientConnection.debug=false\n"
                                     "RemoteProxyClientConnectionTraffic.debug=false\n"
                                     );
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication application(argc, argv);
    application.setApplicationName("nymea-app");
    application.setOrganizationName("nymea");

    // Initialize app log controller as early as possible, but after setting app name etc
    AppLogController::instance();

    foreach (const QFileInfo &fi, QDir(":/ui/fonts/").entryInfoList()) {
        QFontDatabase::addApplicationFont(fi.absoluteFilePath());
    }

    QFont applicationFont;
//    applicationFont.setFamily("Oswald");
    applicationFont.setCapitalization(QFont::MixedCase);
    applicationFont.setPixelSize(16);
    applicationFont.setWeight(QFont::Normal);
    QApplication::setFont(applicationFont);

    QTranslator qtTranslator;    
    qtTranslator.load("qt_" + QLocale::system().name(),
            QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    application.installTranslator(&qtTranslator);

    qDebug() << "Locale info:" << QLocale() << QLocale().name() << QLocale().language() << QLocale().system();

    QTranslator appTranslator;
    bool translationResult = appTranslator.load(QLocale(), "nymea-app", "-", ":/translations/", ".qm");
    if (translationResult) {
        qDebug() << "Loaded translation for locale" << QLocale();
    } else {
        qWarning() << "Failed to load translations for locale" << QLocale();
    }
    application.installTranslator(&appTranslator);

    qDebug() << "Running on" << QSysInfo::machineHostName() << QSysInfo::prettyProductName() << QSysInfo::productType() << QSysInfo::productVersion();

    registerQmlTypes();

    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    qmlRegisterSingletonType<PlatformHelper>("Nymea", 1, 0, "PlatformHelper", platformHelperProvider);

    PushNotifications::instance()->connectClient();
    qmlRegisterSingletonType<PushNotifications>("Nymea", 1, 0, "PushNotifications", PushNotifications::pushNotificationsProvider);

    qmlRegisterSingletonType<AppLogController>("Nymea", 1, 0, "AppLogController", AppLogController::appLogControllerProvider);

#ifdef BRANDING
    engine->rootContext()->setContextProperty("appBranding", BRANDING);
#else
    engine->rootContext()->setContextProperty("appBranding", "");
#endif
    engine->rootContext()->setContextProperty("appVersion", APP_VERSION);
    engine->rootContext()->setContextProperty("qtVersion", QT_VERSION_STR);

    StyleController styleController;
    engine->rootContext()->setContextProperty("styleController", &styleController);

    engine->rootContext()->setContextProperty("systemProductType", QSysInfo::productType());

    engine->rootContext()->setContextProperty("useVirtualKeyboard", qgetenv("QT_IM_MODULE") == "qtvirtualkeyboard");

    application.setWindowIcon(QIcon(QString(":/styles/%1/logo.svg").arg(styleController.currentStyle())));

    engine->load(QUrl(QLatin1String("qrc:/ui/Nymea.qml")));

    return application.exec();
}
