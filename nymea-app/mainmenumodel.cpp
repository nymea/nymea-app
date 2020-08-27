#include "mainmenumodel.h"

MainMenuModel::MainMenuModel(QObject *parent) : QAbstractListModel(parent)
{

}

int MainMenuModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}
