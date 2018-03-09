#include "paramdescriptors.h"
#include "paramdescriptor.h"

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
    return m_list.at(index);
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
