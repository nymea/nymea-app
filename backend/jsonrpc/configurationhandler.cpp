#include "configurationhandler.h"

ConfigurationHandler::ConfigurationHandler(QObject *parent) :
    JsonHandler(parent)
{

}

QString ConfigurationHandler::nameSpace() const
{
    return "Configuration";
}
