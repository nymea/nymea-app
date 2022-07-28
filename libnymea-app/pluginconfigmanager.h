#ifndef PLUGINCONFIGMANAGER_H
#define PLUGINCONFIGMANAGER_H

#include "types/params.h"
#include "types/paramtypes.h"
#include "engine.h"

#include <QObject>

class PluginConfigManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(Plugin* plugin READ plugin WRITE setPlugin NOTIFY pluginChanged)

    Q_PROPERTY(Params *params READ params CONSTANT)

public:
    explicit PluginConfigManager(QObject *parent = nullptr);

    Engine* engine() const;
    void setEngine(Engine *engine);

    Plugin* plugin() const;
    void setPlugin(Plugin *plugin);

    Params *params();
    void setParams(Params *params);

    Q_INVOKABLE int savePluginConfig();

signals:
    void engineChanged();
    void pluginChanged();

private slots:
    void getPluginConfigResponse(int commandId, const QVariantMap &data);

private:
    Engine *m_engine = nullptr;
    Plugin* m_plugin = nullptr;
    Params *m_params = nullptr;

};

#endif // PLUGINCONFIGMANAGER_H
