#ifndef CONFIGUREDHOSTSMODEL_H
#define CONFIGUREDHOSTSMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QUuid>

#include "engine.h"

class ConfiguredHost: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid uuid READ uuid WRITE setUuid NOTIFY uuidChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(Engine* engine READ engine CONSTANT)

public:
    ConfiguredHost(const QUuid &uuid = QUuid(), QObject *parent = nullptr);

    QUuid uuid() const;
    void setUuid(const QUuid &uuid);

    QString name() const;
    void setName(const QString &name);

    Engine* engine() const;

signals:
    void uuidChanged();
    void nameChanged();

private:
    QUuid m_uuid;
    Engine *m_engine = nullptr;
    QString m_name;
};

class ConfiguredHostsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
public:
    enum Roles {
        RoleUuid,
        RoleEngine,
        RoleName,
    };
    Q_ENUM(Roles)
    explicit ConfiguredHostsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentIndex() const;
    void setCurrentIndex(int currentIndex);

    Q_INVOKABLE int indexOf(ConfiguredHost *host) const;
    Q_INVOKABLE ConfiguredHost* get(int index) const;
    Q_INVOKABLE ConfiguredHost* createHost();
    Q_INVOKABLE void removeHost(int index);
    Q_INVOKABLE void move(int from, int to);

signals:
    void countChanged();
    void currentIndexChanged();

private:
    void addHost(ConfiguredHost *host);

    void saveToDisk();

private:
    QList<ConfiguredHost*> m_list;
    int m_currentIndex = 0;
};

class ConfiguredHostsProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(ConfiguredHostsModel* model READ model WRITE setModel NOTIFY modelChanged)

    Q_PROPERTY(QUuid currentHost READ currentHost WRITE setCurrentHost NOTIFY currentHostChanged)
public:
    ConfiguredHostsProxyModel(QObject *parent = nullptr);

    ConfiguredHostsModel* model() const;
    void setModel(ConfiguredHostsModel *model);

    QUuid currentHost() const;
    void setCurrentHost(const QUuid &currentHost);

    Q_INVOKABLE ConfiguredHost* get(int index) const;

signals:
    void modelChanged();
    void currentHostChanged();

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    ConfiguredHostsModel *m_model = nullptr;
    QUuid m_currentHost;
};

#endif // CONFIGUREDHOSTSMODEL_H
