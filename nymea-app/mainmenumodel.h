#ifndef MAINMENUMODEL_H
#define MAINMENUMODEL_H

#include <QAbstractListModel>

class MainMenuItem: public QObject
{
    Q_OBJECT

};

class MainMenuModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit MainMenuModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

private:
    QList<MainMenuItem*> m_list;
};

#endif // MAINMENUMODEL_H
