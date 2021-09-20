#include "configuredhostsmodel.h"

#include <QSettings>

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcApplication)

ConfiguredHostsModel::ConfiguredHostsModel(QObject *parent) : QAbstractListModel(parent)
{
    QSettings settings;
    settings.beginGroup("ConfiguredHosts");
    foreach (const QString &childGroup, settings.childGroups()) {
        settings.beginGroup(childGroup);
        QUuid uuid = settings.value("uuid").toUuid();
        QString cachedName = settings.value("cachedName").toString();
        ConfiguredHost *host = new ConfiguredHost(uuid, this);
        host->setName(cachedName);
        addHost(host);
        settings.endGroup();
    }
    m_currentIndex = settings.value("currentIndex", 0).toInt();
    settings.endGroup();

    // If there aren't any in the config, try migrating settings from old tab model
    if (m_list.isEmpty() && settings.contains("tabCount")) {
        qCInfo(dcApplication()) << "Migrating tab settings to mainmenumodel";
        int tabCount = settings.value("tabCount", 0).toInt();
        qCDebug(dcApplication()) << "Tab count:" << tabCount;

        for (int i = 0; i < tabCount; i++) {
            settings.beginGroup(QString("tabSettings%1").arg(i));
            QUuid uuid = settings.value("lastConnectedHost").toUuid();
            ConfiguredHost *host = new ConfiguredHost(uuid, this);
            addHost(host);
            settings.endGroup();
        }

        settings.remove("tabCount");
    }

    // There must be always 1 at least
    if (m_list.isEmpty()) {
        createHost();
    }

    // Make sure the currentIndex from the config isn't out of place
    if (m_currentIndex >= m_list.count()) {
        m_currentIndex = m_list.count()-1;
    }
}

int ConfiguredHostsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ConfiguredHostsModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleUuid:
        return m_list.at(index.row())->uuid();
    case RoleName:
        if (!m_list.at(index.row())->name().isEmpty()) {
            return m_list.at(index.row())->name();
        }
        return m_list.at(index.row())->uuid();
    }
    return QVariant();
}

QHash<int, QByteArray> ConfiguredHostsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleUuid, "uuid");
    roles.insert(RoleName, "name");
    return roles;
}

ConfiguredHost *ConfiguredHostsModel::get(int index) const
{
    if (index < 0 || index >= m_list.count()) {
        return nullptr;
    }
    return m_list.at(index);
}

int ConfiguredHostsModel::currentIndex() const
{
    return m_currentIndex;
}

void ConfiguredHostsModel::setCurrentIndex(int currentIndex)
{
    if (m_currentIndex != currentIndex) {
        m_currentIndex = currentIndex;
        emit currentIndexChanged();

        QSettings settings;
        settings.beginGroup("ConfiguredHosts");
        settings.setValue("currentIndex", currentIndex);
        settings.endGroup();
    }
}

ConfiguredHost *ConfiguredHostsModel::createHost()
{
    ConfiguredHost *host = new ConfiguredHost();
    addHost(host);
    return host;
}

void ConfiguredHostsModel::removeHost(int index)
{
    if (index < 0 || index >= m_list.count()) {
        qCWarning(dcApplication()) << "Cannot remove connection at index" << index;
        return;
    }
    beginRemoveRows(QModelIndex(), index, index);
    m_list.takeAt(index)->deleteLater();
    saveToDisk();
    endRemoveRows();
    emit countChanged();

    if (m_list.isEmpty()) {
        createHost();
    }

    if (m_currentIndex >= m_list.count()) {
        m_currentIndex = m_list.count() - 1;
        emit currentIndexChanged();
    }
}

int ConfiguredHostsModel::indexOf(ConfiguredHost *host) const
{
    return m_list.indexOf(host);
}

void ConfiguredHostsModel::addHost(ConfiguredHost *host)
{
    host->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    connect(host->engine()->jsonRpcClient(), &JsonRpcClient::currentHostChanged, this, [=]{
        if (host->engine()->jsonRpcClient()->currentHost()) {
            host->setUuid(host->engine()->jsonRpcClient()->currentHost()->uuid());
        } else {
            host->setUuid(QUuid());
            host->setName(QString());
        }
        saveToDisk();
    });
    connect(host->engine()->jsonRpcClient(), &JsonRpcClient::serverNameChanged, this, [=]{
        host->setName(host->engine()->jsonRpcClient()->serverName());
        saveToDisk();
    });
    connect(host, &ConfiguredHost::nameChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(host));
        emit dataChanged(idx, idx, {RoleName});
    });
    connect(host, &ConfiguredHost::uuidChanged, this, [=](){
        saveToDisk();
    });
    m_list.append(host);
    endInsertRows();
    emit countChanged();
}

void ConfiguredHostsModel::saveToDisk()
{
    QSettings settings;
    settings.beginGroup("ConfiguredHosts");
    settings.remove("");
    settings.setValue("currentIndex", m_currentIndex);
    for (int i = 0; i < m_list.count(); i++) {
        settings.beginGroup(QString::number(i));
        settings.setValue("uuid", m_list.at(i)->uuid());
        settings.setValue("cachedName", m_list.at(i)->name());
        settings.endGroup();
    }
    settings.endGroup();
}

ConfiguredHost::ConfiguredHost(const QUuid &uuid, QObject *parent):
    QObject(parent),
    m_uuid(uuid),
    m_engine(new Engine(this))
{

}

QUuid ConfiguredHost::uuid() const
{
    return m_uuid;
}

void ConfiguredHost::setUuid(const QUuid &uuid)
{
    if (m_uuid != uuid) {
        m_uuid = uuid;
        emit uuidChanged();
    }
}

Engine *ConfiguredHost::engine() const
{
    return m_engine;
}

QString ConfiguredHost::name() const
{
    return m_name;
}

void ConfiguredHost::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

ConfiguredHostsProxyModel::ConfiguredHostsProxyModel(QObject *parent):
    QSortFilterProxyModel(parent)
{

}

ConfiguredHostsModel *ConfiguredHostsProxyModel::model() const
{
    return m_model;
}

void ConfiguredHostsProxyModel::setModel(ConfiguredHostsModel *model)
{
    if (m_model != model) {
        m_model = model;
        emit modelChanged();

        setSourceModel(model);
        sort(0);
    }
}

QUuid ConfiguredHostsProxyModel::currentHost() const
{
    return m_currentHost;
}

void ConfiguredHostsProxyModel::setCurrentHost(const QUuid &currentHost)
{
    if (m_currentHost != currentHost) {
        m_currentHost = currentHost;
        emit currentHostChanged();

        invalidate();
    }
}

ConfiguredHost *ConfiguredHostsProxyModel::get(int index) const
{
    return m_model->get(mapToSource(this->index(index, 0)).row());
}

bool ConfiguredHostsProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    ConfiguredHost *left = m_model->get(source_left.row());
    ConfiguredHost *right = m_model->get(source_right.row());

    if (left->uuid() == m_currentHost) {
        return true;
    }
    if (right->uuid() == m_currentHost) {
        return false;
    }
    return source_left.row() < source_right.row();
}
