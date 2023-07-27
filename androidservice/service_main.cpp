#include <QDebug>
#include <QCoreApplication>

#include "nymeaappservice/nymeaappservice.h"
#include "controlviews/devicecontrolapplication.h"

#include <QCommandLineParser>
#include <QLoggingCategory>

int main(int argc, char *argv[])
{
    qWarning() << "Service starting from a separate .so file";

    QLoggingCategory::setFilterRules("qt.remoteobjects.debug=false\n"
                                     "JsonRpc.debug=false\n"
                                     "RuleManager.debug=false\n"
                                     "NymeaConfiguration.debug=false\n"
                                     "ThingManager.debug=false\n");

    QStringList args;
    for (int i = 0; i < argc; i++) {
        args.append(QByteArray(argv[i]));
        qDebug() << "nymea-app: Added command line arg" << args.last();
    }
    QCommandLineParser parser;
    QCommandLineOption controlActivityOption("controlActivity");
    parser.addOption(controlActivityOption);
    parser.parse(args);

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QCoreApplication *app;
    if (parser.isSet(controlActivityOption)) {
        qDebug() << "nymea-app: Starting Device Control Activity";
        app = new DeviceControlApplication(argc, argv);
    } else {
        qDebug() << "nymea-app: Starting NymeaAppService background service";
        app = new NymeaAppService(argc, argv);
    }
    return app->exec();
}
