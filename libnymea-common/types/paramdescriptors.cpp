#include "paramdescriptors.h"
#include "paramdescriptor.h"

#include <QDebug>

ParamDescriptors::ParamDescriptors(QObject *parent) : QAbstractListModel(parent)
{

}

int ParamDescriptors::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ParamDescriptors::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->paramTypeId();
    case RoleValue:
        return m_list.at(index.row())->value();
    case RoleOperator:
        return m_list.at(index.row())->operatorType();
    }
    return QVariant();
}

QHash<int, QByteArray> ParamDescriptors::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleValue, "value");
    roles.insert(RoleOperator, "operator");
    return roles;
}

ParamDescriptor *ParamDescriptors::get(int index) const
{
    if (index >= 0 && index < m_list.count()) {
        return m_list.at(index);
    }
    return nullptr;
}

ParamDescriptor *ParamDescriptors::createNewParamDescriptor() const
{
    return new ParamDescriptor();
}

void ParamDescriptors::addParamDescriptor(ParamDescriptor *paramDescriptor)
{
    paramDescriptor->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(paramDescriptor);
    endInsertRows();
    emit countChanged();
}

void ParamDescriptors::setParamDescriptor(const QString &paramTypeId, const QVariant &value, ValueOperator operatorType)
{
    foreach (ParamDescriptor* paramDescriptor, m_list) {
        if (paramDescriptor->paramTypeId() == paramTypeId) {
            paramDescriptor->setValue(value);
            paramDescriptor->setOperatorType((ParamDescriptor::ValueOperator)operatorType);
            return;
        }
    }
    // Still here? need to add a new one
    ParamDescriptor* paramDescriptor = createNewParamDescriptor();
    paramDescriptor->setParamTypeId(paramTypeId);
    paramDescriptor->setValue(value);
    paramDescriptor->setOperatorType((ParamDescriptor::ValueOperator)operatorType);
    addParamDescriptor(paramDescriptor);
}

void ParamDescriptors::setParamDescriptorByName(const QString &paramName, const QVariant &value, ParamDescriptors::ValueOperator operatorType)
{
    foreach (ParamDescriptor* paramDescriptor, m_list) {
        if (paramDescriptor->paramName() == paramName) {
            paramDescriptor->setValue(value);
            paramDescriptor->setOperatorType((ParamDescriptor::ValueOperator)operatorType);
            return;
        }
    }
    // Still here? need to add a new one
    ParamDescriptor* paramDescriptor = createNewParamDescriptor();
    paramDescriptor->setParamName(paramName);
    paramDescriptor->setValue(value);
    paramDescriptor->setOperatorType((ParamDescriptor::ValueOperator)operatorType);
    addParamDescriptor(paramDescriptor);
}

void ParamDescriptors::clear()
{
    beginResetModel();
    qDeleteAll(m_list);
    m_list.clear();
    endResetModel();
    emit countChanged();
}

ParamDescriptor *ParamDescriptors::getParamDescriptor(const QString &paramTypeId) const
{
    qDebug() << "getParamDescriptor" << paramTypeId;
    for (int i = 0; i < m_list.count(); i++) {
        qDebug() << "have param descriptor:" << m_list.at(i)->paramTypeId();
        if (m_list.at(i)->paramTypeId() == paramTypeId) {
            return m_list.at(i);
        }
    }
    return nullptr;
}

ParamDescriptor *ParamDescriptors::getParamDescriptorByName(const QString &paramName) const
{
    qDebug() << "getParamDescriptorByName" << paramName;
    for (int i = 0; i < m_list.count(); i++) {
        qDebug() << "have param descriptor:" << m_list.at(i)->paramName();
        if (m_list.at(i)->paramName() == paramName) {
            return m_list.at(i);
        }
    }
    return nullptr;
}

bool ParamDescriptors::operator==(ParamDescriptors *other) const
{
    if (rowCount() != other->rowCount()) {
        return false;
    }
    for (int i = 0; i < rowCount(); i++) {
        if (!get(i)->operator==(other->get(i))) {
            return false;
        }
    }
    return true;
}
