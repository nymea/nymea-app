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

#ifndef APPLOGCONTROLLER_H
#define APPLOGCONTROLLER_H

#include <QObject>
#include <QFile>
#include <QQmlEngine>
#include <QAbstractListModel>
#include <QMutex>

class AppLogController : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool canWriteLogs READ canWriteLogs CONSTANT)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString logFile READ logFile CONSTANT)

public:
    enum Type {
        TypeInfo,
        TypeWarning
    };
    Q_ENUM(Type)

    enum Roles {
        RoleText,
        RoleType
    };
    Q_ENUM(Roles)

    static QObject* appLogControllerProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    static AppLogController* instance();

    bool canWriteLogs() const;

    bool enabled() const;
    void setEnabled(bool enabled);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &parent, int role) const override;
    QHash<int, QByteArray> roleNames() const override;


    Q_INVOKABLE void toClipboard();

    QString logFile() const;

signals:
    void enabledChanged();

private:
    explicit AppLogController(QObject *parent = nullptr);
    static QtMessageHandler s_oldLogMessageHandler;
    static void logMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message);

    void append(const QString &message, Type type = TypeInfo);

    void activate();
    void deactivate();

    QFile m_logFile;
    QStringList m_buffer;
    QList<Type> m_types;
    QMutex m_mutex;
};

#endif // APPLOGCONTROLLER_H
