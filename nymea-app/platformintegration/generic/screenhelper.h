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

#ifndef RASPBERRYPIHELPER_H
#define RASPBERRYPIHELPER_H

#include <QObject>
#include <QTimer>
#include <QFile>

class ScreenHelper : public QObject
{
    Q_OBJECT
public:
    explicit ScreenHelper(QObject *parent = nullptr);

    bool active() const;
    int screenTimeout() const;
    void setScreenTimeout(int timeout);

    int screenBrightness() const;
    void setScreenBrightness(int percent);

    bool eventFilter(QObject *watched, QEvent *event) override;

private slots:
    void screenOn();
    void screenOff();
    void dimScreen();

    void applyBrightness(int percent);

private:
    QTimer m_screenOffTimer;
    QTimer m_screenDimTimer;
    QFile m_powerFile;
    QFile m_brightnessFile;

    bool m_cursorHidden = false;

    int m_maxBrightness = -1;
    int m_currentBrightness = 255;
};

#endif // RASPBERRYPIHELPER_H
