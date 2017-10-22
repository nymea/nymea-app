#ifndef CONFIGURATIONHANDLER_H
#define CONFIGURATIONHANDLER_H

#include <QObject>

#include "jsonhandler.h"

class ConfigurationHandler : public JsonHandler
{
    Q_OBJECT
public:
    explicit ConfigurationHandler(QObject *parent = 0);

    QString nameSpace() const;

signals:

public slots:
};

#endif // CONFIGURATIONHANDLER_H
