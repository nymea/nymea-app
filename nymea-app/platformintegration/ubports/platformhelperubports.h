#ifndef PLATFORMHELPERUBPORTS_H
#define PLATFORMHELPERUBPORTS_H

#include <QObject>

#include "platformhelper.h"

class PlatformHelperUBPorts : public PlatformHelper
{
    Q_OBJECT
public:
    explicit PlatformHelperUBPorts(QObject *parent = nullptr);

    QString platform() const override;

signals:

};

#endif // PLATFORMHELPERUBPORTS_H
