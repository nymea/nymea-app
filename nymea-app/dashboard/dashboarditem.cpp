#include "dashboarditem.h"
#include "dashboardmodel.h"

#include <QDebug>

DashboardItem::DashboardItem(const QString &type, QObject *parent):
    QObject(parent),
    m_type(type)
{

}

QString DashboardItem::type() const
{
    return m_type;
}

int DashboardItem::columnSpan() const
{
    return m_columnSpan;
}

void DashboardItem::setColumnSpan(int columnSpan)
{
    if (m_columnSpan != columnSpan) {
        m_columnSpan = columnSpan;
        emit columnSpanChanged();
        emit changed();
    }
}

int DashboardItem::rowSpan() const
{
    return m_rowSpan;
}

void DashboardItem::setRowSpan(int rowSpan)
{
    if (m_rowSpan != rowSpan) {
        m_rowSpan = rowSpan;
        qCritical() << "emitting changed";
        emit rowSpanChanged();
        emit changed();
    }
}

DashboardThingItem::DashboardThingItem(const QUuid &thingId, QObject *parent):
    DashboardItem("thing", parent),
    m_thingId(thingId)
{

}

QUuid DashboardThingItem::thingId() const
{
    return m_thingId;
}

DashboardFolderItem::DashboardFolderItem(const QString &name, const QString &icon, QObject *parent):
    DashboardItem("folder", parent),
    m_name(name),
    m_icon(icon)
{
    m_model = new DashboardModel(this);
    connect(m_model, &DashboardModel::changed, this, &DashboardItem::changed);
}

QString DashboardFolderItem::name() const
{
    return m_name;
}

void DashboardFolderItem::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
        emit changed();
    }
}

QString DashboardFolderItem::icon() const
{
    return m_icon;
}

void DashboardFolderItem::setIcon(const QString &icon)
{
    if (m_icon != icon) {
        m_icon = icon;
        emit iconChanged();
        emit changed();
    }
}

DashboardModel *DashboardFolderItem::model() const
{
    return m_model;
}

DashboardGraphItem::DashboardGraphItem(const QUuid &thingId, const QUuid &stateTypeId, QObject *parent):
    DashboardItem("graph", parent),
    m_thingId(thingId),
    m_stateTypeId(stateTypeId)
{
    setColumnSpan(2);
}

QUuid DashboardGraphItem::thingId() const
{
    return m_thingId;
}

QUuid DashboardGraphItem::stateTypeId() const
{
    return m_stateTypeId;
}

DashboardSceneItem::DashboardSceneItem(const QUuid &ruleId, QObject *parent):
    DashboardItem("scene", parent),
    m_ruleId(ruleId)
{

}

QUuid DashboardSceneItem::ruleId() const
{
    return m_ruleId;
}

DashboardWebViewItem::DashboardWebViewItem(const QUrl &url, bool interactive, QObject *parent):
    DashboardItem("webview", parent),
    m_url(url),
    m_interactive(interactive)
{

}

QUrl DashboardWebViewItem::url() const
{
    return m_url;
}

void DashboardWebViewItem::setUrl(const QUrl &url)
{
    if (m_url != url) {
        m_url = url;
        emit urlChanged();
        emit changed();
    }
}

bool DashboardWebViewItem::interactive() const
{
    return m_interactive;
}

void DashboardWebViewItem::setInteractive(bool interactive)
{
    if (m_interactive != interactive) {
        m_interactive = interactive;
        emit interactiveChanged();
        emit changed();
    }
}

DashboardStateItem::DashboardStateItem(const QUuid &thingId, const QUuid &stateTypeId, QObject *parent):
    DashboardItem("state", parent),
    m_thingId(thingId),
    m_stateTypeId(stateTypeId)
{
}

QUuid DashboardStateItem::thingId() const
{
    return m_thingId;
}

QUuid DashboardStateItem::stateTypeId() const
{
    return m_stateTypeId;
}
