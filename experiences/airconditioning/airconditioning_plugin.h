#ifndef AIRCONDITIONING_PLUGIN_H
#define AIRCONDITIONING_PLUGIN_H

#include <QQmlExtensionPlugin>

class AirconditioningPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override;
};

#endif // AIRCONDITIONING_PLUGIN_H
