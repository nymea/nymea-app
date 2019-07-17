#ifndef BROWSERITEMS_H
#define BROWSERITEMS_H

#include <QAbstractListModel>
#include <QUuid>

class BrowserItem;

class BrowserItems: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
public:
    enum Roles {
        RoleId,
        RoleDisplayName,
        RoleDescription,
        RoleIcon,
        RoleThumbnail,
        RoleBrowsable,
        RoleExecutable,
        RoleDisabled,
        RoleActionTypeIds,

        RoleMediaIcon,
    };
    Q_ENUM(Roles)

    explicit BrowserItems(const QUuid &deviceId, const QString &itemId, QObject *parent = nullptr);
    virtual ~BrowserItems() override;

    QUuid deviceId() const;
    QString itemId() const;

    bool busy() const;

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    virtual void addBrowserItem(BrowserItem *browserItem);

    void removeItem(BrowserItem *browserItem);

    QList<BrowserItem*> list() const;
    void setBusy(bool busy);

    Q_INVOKABLE virtual BrowserItem* get(int index) const;
    Q_INVOKABLE virtual BrowserItem* getBrowserItem(const QString &itemId);

//    void clear();

signals:
    void countChanged();
    void busyChanged();

protected:
    bool m_busy = false;
    QList<BrowserItem*> m_list;

    QUuid m_deviceId;
    QString m_itemId;
};

#endif // BROWSERITEMS_H
