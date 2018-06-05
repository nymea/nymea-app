/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of mea.                                      *
 *                                                                         *
 *  mea is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  mea is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with mea. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <QGuiApplication>
#include <QCommandLineParser>
#include <QtQml/QQmlContext>
#include <QQmlApplicationEngine>
#include <QtQuickControls2>
#include <QSysInfo>

#include "libmea-core.h"

#include "stylecontroller.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication application(argc, argv);
    application.setApplicationName("mea");
    application.setOrganizationName("nymea");

    foreach (const QFileInfo &fi, QDir(":/ui/fonts/").entryInfoList()) {
        int id = QFontDatabase::addApplicationFont(fi.absoluteFilePath());
        qDebug() << "Added font" << fi.absoluteFilePath() << QFontDatabase::applicationFontFamilies(id);
    }

    QFont applicationFont;
    applicationFont.setFamily("Ubuntu");
    applicationFont.setCapitalization(QFont::MixedCase);
    applicationFont.setPixelSize(16);
    applicationFont.setWeight(QFont::Normal);
    QGuiApplication::setFont(applicationFont);

    QTranslator qtTranslator;    
    qtTranslator.load("qt_" + QLocale::system().name(),
            QLibraryInfo::location(QLibraryInfo::TranslationsPath));
    application.installTranslator(&qtTranslator);

    QTranslator meaTranslator;
    qDebug() << "Loading translation file:" << ":/translations/mea-" + QLocale::system().name();
    meaTranslator.load(":/translations/mea-" + QLocale::system().name());
    application.installTranslator(&meaTranslator);

    qDebug() << "Running on" << QSysInfo::machineHostName() << QSysInfo::prettyProductName() << QSysInfo::productType() << QSysInfo::productVersion();

    registerQmlTypes();

    Engine::instance();

    QQmlApplicationEngine *engine = new QQmlApplicationEngine();
#ifdef BRANDING
    engine->rootContext()->setContextProperty("appBranding", BRANDING);
#else
    engine->rootContext()->setContextProperty("appBranding", "");
#endif
    engine->rootContext()->setContextProperty("appVersion", MEA_VERSION);
    engine->rootContext()->setContextProperty("qtVersion", QT_VERSION_STR);

    StyleController styleController;
    engine->rootContext()->setContextProperty("styleController", &styleController);

    engine->load(QUrl(QLatin1String("qrc:/ui/Mea.qml")));

    return application.exec();
}
