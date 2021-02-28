#ifndef DASHBOARDMODEL_H
#define DASHBOARDMODEL_H

#include <QAbstractListModel>

class DashboardItem;

class DashboardModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleType,
        RoleColumnSpan,
        RoleRowSpan,
    };
    Q_ENUM(Roles)

    explicit DashboardModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE DashboardItem* get(int index) const;

    Q_INVOKABLE void addThingItem(const QUuid &thingId, int index = -1);
    Q_INVOKABLE void addFolderItem(const QString &name, const QString &icon, int index = -1);
    Q_INVOKABLE void addGraphItem(const QUuid &thingId, const QUuid &stateTypeId, int index = -1);
    Q_INVOKABLE void addSceneItem(const QUuid &ruleId, int index = -1);
    Q_INVOKABLE void addWebViewItem(const QUrl &url, int columnSpan, int rowSpan, bool interactive, int index = -1);

    Q_INVOKABLE void removeItem(int index);
    Q_INVOKABLE void move(int from, int to);

    Q_INVOKABLE void loadFromJson(const QByteArray &json);
    Q_INVOKABLE QByteArray toJson() const;
signals:
    void changed();
    void countChanged();

    void save();

private:
    void addItem(DashboardItem *item, int index = -1);

private:
    QList<DashboardItem*> m_list;

};


#endif // DASHBOARDMODEL_H
