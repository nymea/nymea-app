#ifndef DASHBOARDITEM_H
#define DASHBOARDITEM_H

#include <QObject>
#include <QUuid>
#include <QUrl>

class DashboardModel;

class DashboardItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString type READ type CONSTANT)
    Q_PROPERTY(int columnSpan READ columnSpan WRITE setColumnSpan NOTIFY columnSpanChanged)
    Q_PROPERTY(int rowSpan READ rowSpan WRITE setRowSpan NOTIFY rowSpanChanged)
public:
    explicit DashboardItem(const QString &type, QObject *parent = nullptr);
    QString type() const;
    int columnSpan() const;
    void setColumnSpan(int columnSpan);
    int rowSpan() const;
    void setRowSpan(int rowSpan);
signals:
    // For convenience when *any* change needs to be tracked
    void changed();

    void columnSpanChanged();
    void rowSpanChanged();
private:
    QString m_type;
    int m_columnSpan = 1;
    int m_rowSpan = 1;
};

class DashboardThingItem: public DashboardItem
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
public:
    explicit DashboardThingItem(const QUuid &thingId, QObject *parent = nullptr);

    QUuid thingId() const;
private:
    QUuid m_thingId;
};

class DashboardFolderItem: public DashboardItem
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString icon READ icon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(DashboardModel* model READ model CONSTANT)
public:
    explicit DashboardFolderItem(const QString &name, const QString &icon, QObject *parent = nullptr);
    QString name() const;
    void setName(const QString &name);
    QString icon() const;
    void setIcon(const QString &icon);
    DashboardModel *model() const;
signals:
    void nameChanged();
    void iconChanged();
private:
    QString m_name;
    QString m_icon;
    DashboardModel *m_model= nullptr;
};

class DashboardGraphItem: public DashboardItem
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
    Q_PROPERTY(QUuid stateTypeId READ stateTypeId CONSTANT)
public:
    explicit DashboardGraphItem(const QUuid &thingId, const QUuid &stateTypeId, QObject *parent = nullptr);
    QUuid thingId() const;
    QUuid stateTypeId() const;
private:
    QUuid m_thingId;
    QUuid m_stateTypeId;
};

class DashboardSceneItem: public DashboardItem
{
    Q_OBJECT
    Q_PROPERTY(QUuid ruleId READ ruleId CONSTANT)
public:
    explicit DashboardSceneItem(const QUuid &ruleId, QObject *parent = nullptr);
    QUuid ruleId() const;
private:
    QUuid m_ruleId;
};

class DashboardWebViewItem: public DashboardItem
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(bool interactive READ interactive WRITE setInteractive NOTIFY interactiveChanged)
public:
    explicit DashboardWebViewItem(const QUrl &url, bool interactive = false, QObject *parent = nullptr);
    QUrl url() const;
    void setUrl(const QUrl &url);
    bool interactive() const;
    void setInteractive(bool interactive);
signals:
    void urlChanged();
    void interactiveChanged();
private:
    QUrl m_url;
    bool m_interactive = false;
};

class DashboardStateItem: public DashboardItem
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
    Q_PROPERTY(QUuid stateTypeId READ stateTypeId CONSTANT)
public:
    explicit DashboardStateItem(const QUuid &thingId, const QUuid &stateTypeId, QObject *parent = nullptr);
    QUuid thingId() const;
    QUuid stateTypeId() const;
private:
    QUuid m_thingId;
    QUuid m_stateTypeId;
};

class DashboardSensorItem: public DashboardItem
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
    Q_PROPERTY(QStringList interfaces READ interfaces CONSTANT)
public:
    explicit DashboardSensorItem(const QUuid &thingId, const QStringList &interfaces, QObject *parent = nullptr);
    QUuid thingId() const;
    QStringList interfaces() const;
private:
    QUuid m_thingId;
    QStringList m_interfaces;
};

#endif // DASHBOARDITEM_H
