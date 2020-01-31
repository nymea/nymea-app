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

#ifndef TAGSPROXYMODEL_H
#define TAGSPROXYMODEL_H

#include <QSortFilterProxyModel>

class Tag;
class Tags;

class TagsProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Tags* tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString filterTagId READ filterTagId WRITE setFilterTagId NOTIFY filterTagIdChanged)
    Q_PROPERTY(QString filterDeviceId READ filterDeviceId WRITE setFilterDeviceId NOTIFY filterDeviceIdChanged)
    Q_PROPERTY(QString filterRuleId READ filterRuleId WRITE setFilterRuleId NOTIFY filterRuleIdChanged)

public:
    explicit TagsProxyModel(QObject *parent = nullptr);

    Tags* tags() const;
    void setTags(Tags* tags);

    QString filterTagId() const;
    void setFilterTagId(const QString &filterTagId);

    QString filterDeviceId() const;
    void setFilterDeviceId(const QString &filterDeviceId);

    QString filterRuleId() const;
    void setFilterRuleId(const QString &filterRuleId);

    Q_INVOKABLE Tag* get(int index) const;
    Q_INVOKABLE Tag* findTag(const QString &tagId) const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

signals:
    void tagsChanged();
    void filterTagIdChanged();
    void filterDeviceIdChanged();
    void filterRuleIdChanged();
    void groupSameTagsChanged();
    void countChanged();

private:
    Tags *m_tags = nullptr;
    QString m_filterTagId;
    QString m_filterDeviceId;
    QString m_filterRuleId;
};

#endif // TAGSPROXYMODEL_H
