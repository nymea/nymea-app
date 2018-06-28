#include "tags.h"
#include "tag.h"

#include <QDebug>

Tags::Tags(QObject *parent) : QAbstractListModel(parent)
{

}

int Tags::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant Tags::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleDeviceId:
        return m_list.at(index.row())->deviceId();
    case RoleRuleId:
        return m_list.at(index.row())->ruleId();
    case RoleTagId:
        return m_list.at(index.row())->tagId();
    case RoleValue:
        return m_list.at(index.row())->value();
    }
    return QVariant();
}

QHash<int, QByteArray> Tags::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleDeviceId, "deviceId");
    roles.insert(RoleRuleId, "ruleId");
    roles.insert(RoleTagId, "tagId");
    roles.insert(RoleValue, "value");
    return roles;
}

void Tags::addTag(Tag *tag)
{
    tag->setParent(this);
    connect(tag, &Tag::valueChanged, this, &Tags::tagValueChanged);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(tag);
    endInsertRows();
    emit countChanged();
}

void Tags::removeTag(Tag *tag)
{
    int idx = m_list.indexOf(tag);
    if (idx < 0) {
        qWarning() << "Don't know this tag. Can't remove";
        return;
    }
    beginRemoveRows(QModelIndex(), idx, idx);
    m_list.removeAt(idx);
    endRemoveRows();
    tag->deleteLater();
    emit countChanged();
}

Tag *Tags::get(int index) const
{
    return m_list.at(index);
}

Tag *Tags::findDeviceTag(const QString &deviceId, const QString &tagId) const
{
    foreach (Tag *tag, m_list) {
        if (tag->deviceId() == deviceId && tag->tagId() == tagId) {
            return tag;
        }
    }
    return nullptr;
}

Tag *Tags::findRuleTag(const QString &ruleId, const QString &tagId) const
{
    foreach (Tag *tag, m_list) {
        if (tag->ruleId() == ruleId && tag->tagId() == tagId) {
            return tag;
        }
    }
    return nullptr;
}

void Tags::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

void Tags::tagValueChanged()
{
    qDebug() << "Tag value in mode changed";
    Tag *tag = static_cast<Tag*>(sender());
    int idx = m_list.indexOf(tag);
    emit dataChanged(index(idx, 0), index(idx, 0), {RoleValue});
}
