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
    return QVariant();
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
        if (paramDescriptor->id() == paramTypeId) {
            paramDescriptor->setValue(value);
            paramDescriptor->setOperatorType((ParamDescriptor::ValueOperator)operatorType);
            return;
        }
    }
    // Still here? need to add a new one
    ParamDescriptor* paramDescriptor = createNewParamDescriptor();
    paramDescriptor->setId(paramTypeId);
    paramDescriptor->setValue(value);
    paramDescriptor->setOperatorType((ParamDescriptor::ValueOperator)operatorType);
    addParamDescriptor(paramDescriptor);
}
