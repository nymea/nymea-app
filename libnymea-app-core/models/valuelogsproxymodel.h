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

#ifndef VALUELOGSPROXYMODEL_H
#define VALUELOGSPROXYMODEL_H

#include <QAbstractListModel>

#include "logsmodel.h"

class ValueLogsProxyModel : public LogsModel
{
    Q_OBJECT
    Q_PROPERTY(Average average READ average WRITE setAverage NOTIFY averageChanged)

    Q_PROPERTY(QVariant minimumValue READ minimumValue NOTIFY minimumValueChanged)
    Q_PROPERTY(QVariant maximumValue READ maximumValue NOTIFY maximumValueChanged)

public:
    enum Average {
        AverageMonth,
        AverageDay,
        AverageDayTime,
        AverageHourly,
        AverageQuarterHour,
        AverageMinute
    };
    Q_ENUM(Average)

    explicit ValueLogsProxyModel(QObject *parent = nullptr);

    void update() override;

    Average average() const;
    void setAverage(Average average);

    QVariant minimumValue() const;
    QVariant maximumValue() const;

signals:
    void averageChanged();

    void minimumValueChanged();
    void maximumValueChanged();

protected:
    void logsReply(const QVariantMap &data) override;

private:
    Average m_average = AverageHourly;

    QVariant m_minimumValue;
    QVariant m_maximumValue;
};

#endif // VALUELOGSPROXYMODEL_H
