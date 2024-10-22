# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: nil -*-
# vi: set ft=python sts=4 ts=4 sw=4 et:

from PyQt4.QtCore import *
from PyQt4.QtGui import *

from ..utils import *
from growdialog import GrowDialog
from watersheddialog import WatershedDialog
from slicdialog import SLICDialog
from clusterdialog import ClusterDialog
from intersectdialog import IntersectDialog
from localmaxdialog import LocalMaxDialog
from smoothingdialog import SmoothingDialog
from binarizationdialog import VolBinarizationDialog
from froi.algorithm.imtool import inverse_transformation


class BasicWidget(QDialog):
    """Model for tools tabwidget."""

    def __init__(self, model, main_win, parent=None):
        super(BasicWidget, self).__init__(parent)
        self._icon_dir = get_icon_dir()

        self._init_gui()
        self._create_actions()
        self._main_win = main_win
        self._model = model

    def _init_gui(self):
        """Initialize GUI."""
        self.grow_button = QPushButton()
        self.grow_button.setFocusPolicy(Qt.NoFocus)
        self.grow_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                    'grow.png')))
        self.grow_button.setEnabled(True)
        self.grow_button.setToolTip("Region Growing")

        self.watershed_button = QPushButton()
        self.watershed_button.setFocusPolicy(Qt.NoFocus)
        self.watershed_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                         'watershed.png')))
        self.watershed_button.setEnabled(True)
        self.watershed_button.setToolTip("Watershed")

        self.slic_button = QPushButton()
        self.slic_button.setFocusPolicy(Qt.NoFocus)
        self.slic_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                         'slic.png')))
        self.slic_button.setEnabled(True)
        self.slic_button.setToolTip("SLIC")

        self.cluster_button = QPushButton()
        self.cluster_button.setFocusPolicy(Qt.NoFocus)
        self.cluster_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                       'cluster.png')))
        self.cluster_button.setEnabled(True)
        self.cluster_button.setToolTip("Cluster")

        self.localmax_button = QPushButton()
        self.localmax_button.setFocusPolicy(Qt.NoFocus)
        self.localmax_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                        'localmax.png')))
        self.localmax_button.setEnabled(True)
        self.localmax_button.setToolTip("Local Max")

        self.intersect_button = QPushButton()
        self.intersect_button.setFocusPolicy(Qt.NoFocus)
        self.intersect_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                         'intersect.png')))
        self.intersect_button.setEnabled(True)
        self.intersect_button.setToolTip("Intersection")

        self.inverse_button = QPushButton()
        self.inverse_button.setFocusPolicy(Qt.NoFocus)
        self.inverse_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                       'inverse.png')))
        self.inverse_button.setEnabled(True)
        self.inverse_button.setToolTip("Inverse")

        self.smooth_button = QPushButton()
        self.smooth_button.setFocusPolicy(Qt.NoFocus)
        self.smooth_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                      'smoothing.png')))
        self.smooth_button.setEnabled(True)
        self.smooth_button.setToolTip("Smooth")

        self.bin_button = QPushButton()
        self.bin_button.setFocusPolicy(Qt.NoFocus)
        self.bin_button.setIcon(QIcon(os.path.join(self._icon_dir,
                                                   'binarization.png')))
        self.bin_button.setEnabled(True)
        self.bin_button.setToolTip("Binarization")

        gridlayout = QGridLayout(self)
        gridlayout.addWidget(self.grow_button, 0, 0)
        gridlayout.addWidget(self.watershed_button, 0, 1)
        gridlayout.addWidget(self.slic_button, 0, 2)
        gridlayout.addWidget(self.cluster_button, 1, 0)
        gridlayout.addWidget(self.localmax_button, 1, 1)
        gridlayout.addWidget(self.intersect_button, 1, 2)
        gridlayout.addWidget(self.inverse_button, 2, 0)
        gridlayout.addWidget(self.bin_button, 2, 1)
        gridlayout.addWidget(self.smooth_button, 2, 2)

    def _create_actions(self):
        """Create actions about the toobar."""
        self.grow_button.clicked.connect(self._grow_clicked)
        self.watershed_button.clicked.connect(self._watershed_clicked)
        self.slic_button.clicked.connect(self._slic_clicked)
        self.cluster_button.clicked.connect(self._cluster_clicked)
        self.localmax_button.clicked.connect(self._localmax_clicked)
        self.intersect_button.clicked.connect(self._intersect_clicked)
        self.inverse_button.clicked.connect(self._inverse_clicked)
        self.bin_button.clicked.connect(self._binary_clicked)
        self.smooth_button.clicked.connect(self._smooth_clicked)

    def _grow_clicked(self):
        """Region growing clicked."""
        if self.grow_button.isEnabled():
            new_dialog = GrowDialog(self._model, self._main_win)
            new_dialog.exec_()

    def _watershed_clicked(self):
        """Watershed clicked"""
        if self.watershed_button.isEnabled():
            new_dialog = WatershedDialog(self._model, self)
            new_dialog.exec_()

    def _slic_clicked(self):
        """Supervoxel clicked."""
        if self.slic_button.isEnabled():
            new_dialog = SLICDialog(self._model, self)
            new_dialog.exec_()

    def _cluster_clicked(self):
        """Run cluster labeling."""
        new_dialog = ClusterDialog(self._model)
        new_dialog.exec_()

    def _localmax_clicked(self):
        """Localmax button clicked."""
        new_dialog = LocalMaxDialog(self._model, self._main_win)
        new_dialog.exec_()

    def _intersect_clicked(self):
        """Make a intersection between two layers."""
        new_dialog = IntersectDialog(self._model)
        new_dialog.exec_()

    def _inverse_clicked(self):
        """Inverse current selected image by multiplying with -1."""
        # get data and name from the current selected image
        index = self._model.currentIndex()
        data = self._model.data(index, Qt.UserRole + 6)
        name = self._model.data(index, Qt.DisplayRole)
        # inverse process
        new_data = inverse_transformation(data)
        new_name = 'inv_' + name
        # save result as a new image
        self._model.addItem(new_data, None, new_name,
                            self._model.data(index, Qt.UserRole + 11))

    def _smooth_clicked(self):
        new_dialog = SmoothingDialog(self._model)
        new_dialog.exec_()

    def _binary_clicked(self):
        new_dialog = VolBinarizationDialog(self._model)
        new_dialog.exec_()
