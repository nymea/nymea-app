/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

    Q_INVOKABLE void setParamDescriptor(const QUuid &paramTypeId, const QVariant &value, ValueOperator operatorType);
    Q_INVOKABLE void setParamDescriptorByName(const QString &paramName, const QVariant &value, ValueOperator operatorType);
    Q_INVOKABLE void clear();

    Q_INVOKABLE ParamDescriptor *getParamDescriptor(const QUuid &paramTypeId) const;
    Q_INVOKABLE ParamDescriptor *getParamDescriptorByName(const QString &paramName) const;

    bool operator==(ParamDescriptors *other) const;

signals:
    void countChanged();

private:
    QList<ParamDescriptor*> m_list;
};

#endif // PARAMDESCRIPTORS_H
