#ifndef PARAMDESCRIPTORS_H
#define PARAMDESCRIPTORS_H

#include <QAbstractListModel>

#include "paramdescriptor.h"

class ParamDescriptors : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum ValueOperator {
        ValueOperatorEquals,
        ValueOperatorNotEquals,
        ValueOperatorLess,
        ValueOperatorGreater,
        ValueOperatorLessOrEqual,
        ValueOperatorGreaterOrEqual
    };
    Q_ENUM(ValueOperator)

    enum Roles {
        RoleId,
        RoleValue,
        RoleOperator
    };
    Q_ENUM(Roles)

    explicit ParamDescriptors(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE ParamDescriptor* get(int index) const;

    ParamDescriptor* createNewParamDescriptor() const;
    void addParamDescriptor(ParamDescriptor* paramDescriptor);

    Q_INVOKABLE void setParamDescriptor(const QString &paramTypeId, const QVariant &value, ValueOperator operatorType);
    Q_INVOKABLE void setParamDescriptorByName(const QString &paramName, const QVariant &value, ValueOperator operatorType);
    Q_INVOKABLE void clear();

    Q_INVOKABLE ParamDescriptor *getParamDescriptor(const QString &paramTypeId) const;
    Q_INVOKABLE ParamDescriptor *getParamDescriptorByName(const QString &paramName) const;

    bool operator==(ParamDescriptors *other) const;

signals:
    void countChanged();

private:
    QList<ParamDescriptor*> m_list;
};

#endif // PARAMDESCRIPTORS_H
