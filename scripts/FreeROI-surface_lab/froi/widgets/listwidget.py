# emacs: -*- mode: python; py-indent-offset: 4; indent-tabs-mode: nil -*-
# vi: set ft=python sts=4 ts=4 sw=4 et:
"""A viewer (part of Qt model-view-delegate classes) for layer selection 
and parameters alternating.

"""

from numpy import array_equal
from numpy import around
from PyQt4.QtCore import *
from PyQt4.QtGui import *

from ..core.labelconfig import LabelConfig
from toolstabwidget import ToolsTabWidget
from basicwidget import BasicWidget
from ..utils import *


class LayerView(QWidget):
    """Implementation a widget for layer selection and parameters alternating.

    Inherits QWidget.
    """
    current_changed = pyqtSignal()

    builtin_colormap = ['gray',
                        'red2yellow',
                        'blue2cyanblue',
                        'red',
                        'green',
                        'blue',
                        'rainbow',
                        'single ROI']

    def __init__(self, label_config_center, parent=None):
        """Initialize the widget."""
        super(LayerView, self).__init__(parent)
        self.setSizePolicy(QSizePolicy.Maximum, QSizePolicy.Expanding)
        self.setMaximumWidth(280)
        self._icon_dir = get_icon_dir()
        self.label_config_center = label_config_center

        # initialize the model
        self._model = None

    def _init_gui(self):
        """Initialize a GUI designation."""
        # initialize QListView
        self._list_view = QListView()
        
        # initialize up/down push button
        button_size=QSize(12,12)
        self._up_button = QPushButton()
        self._up_button.setIcon(QIcon(os.path.join(
                            self._icon_dir, 'arrow_up.png')))
        self._up_button.setIconSize(button_size)
        self._down_button = QPushButton()
        self._down_button.setIcon(QIcon(os.path.join(
                            self._icon_dir, 'arrow_down.png')))
        self._down_button.setIconSize(button_size)
     
        # layout config for list_view panel
        button_layout = QHBoxLayout()

        # initialize parameter selection widgets
        visibility_label = QLabel('Visibility')
        self._visibility = QSlider(Qt.Horizontal)
        self._visibility.setMinimum(0)
        self._visibility.setMaximum(100)
        self._visibility.setSingleStep(5)

        button_layout.addWidget(visibility_label)    
        button_layout.addWidget(self._visibility)
        button_layout.addWidget(self._up_button)
        button_layout.addWidget(self._down_button)

        max_label = QLabel('Max:')
        self._view_max = QLineEdit()
        min_label = QLabel('Min:')
        self._view_min = QLineEdit()
        colormap_label = QLabel('Colormap:')
        self._colormap = QComboBox()
        colormaps = self.builtin_colormap + \
                self.label_config_center.get_all_labelconfig_names()
        self._colormap.addItems(colormaps)

        # initialize parameter selection panel
        grid_layout = QGridLayout()
        grid_layout.addWidget(colormap_label, 1, 0)
        grid_layout.addWidget(self._colormap, 1, 1, 1, 3)

        para_layout = QHBoxLayout()
        para_layout.addWidget(min_label)
        para_layout.addWidget(self._view_min)
        para_layout.addWidget(max_label)
        para_layout.addWidget(self._view_max)

        list_view_layout = QVBoxLayout()
        list_view_layout.addWidget(self._list_view)
        list_view_layout.addLayout(button_layout)
        list_view_layout.addLayout(para_layout) 
        list_view_layout.addLayout(grid_layout)

        # initialize cursor coord&value widgets
        coord_x_label = QLabel('X:')
        self._coord_x = QSpinBox()
        self._coord_x.setRange(0, self._model.getY()-1)
        self._space_x = QLineEdit()
        #self._space_x.setReadOnly(True)
        coord_y_label = QLabel('Y:')
        self._coord_y = QSpinBox()
        self._coord_y.setRange(0, self._model.getX()-1)
        self._space_y = QLineEdit()
        #self._space_y.setReadOnly(True)
        coord_z_label = QLabel('Z:')
        self._coord_z = QSpinBox()
        self._coord_z.setRange(0, self._model.getZ()-1)
        self._space_z = QLineEdit()
        #self._space_z.setReadOnly(True)
        # Set time point
        time_point_label = QLabel('Volume:')
        self._volume_index_spinbox = QSpinBox()
        self._volume_index_spinbox.setValue(0)
        # voxel value
        coord_value_label = QLabel('Value:')
        self._coord_value = QLineEdit()
        self._coord_value.setReadOnly(True)
        # RAS sapce name
        space_label = QLabel('Coordinate space: ')
        space_name = QLabel(self._model.get_space_name())
        # layout
        tv_layout = QHBoxLayout()
        tv_layout.addWidget(time_point_label)
        tv_layout.addWidget(self._volume_index_spinbox)
        tv_layout.addWidget(coord_value_label)
        tv_layout.addWidget(self._coord_value)
        space_layout = QHBoxLayout()
        space_layout.addWidget(space_label)
        space_layout.addWidget(space_name)
        glayout = QGridLayout()
        glayout.addWidget(coord_x_label, 0, 0)
        glayout.addWidget(self._coord_x, 0, 1)
        glayout.addWidget(self._space_x, 0, 2)
        glayout.addWidget(coord_y_label, 1, 0)
        glayout.addWidget(self._coord_y, 1, 1)
        glayout.addWidget(self._space_y, 1, 2)
        glayout.addWidget(coord_z_label, 2, 0)
        glayout.addWidget(self._coord_z, 2, 1)
        glayout.addWidget(self._space_z, 2, 2)
        glayout.addLayout(tv_layout, 3, 0, 1, 4)
        glayout.addLayout(space_layout, 4, 0, 1, 4)
       
        self._cursor_info_panel = QGroupBox('Cursor')
        self._cursor_info_panel.setLayout(glayout)

        self._unity_info_panel = QGroupBox('Common Tools')
        self._unity_tabwidget = QTabWidget()
        self.basic_widget = BasicWidget(self._model, self)
        self.ROItools_widget = ToolsTabWidget(self._model, self)

        self._unity_tabwidget.addTab(self.basic_widget, "Basic")
        self._unity_tabwidget.addTab(self.ROItools_widget, "ROI")

        hlayout = QHBoxLayout(self._unity_info_panel)
        hlayout.addWidget(self._unity_tabwidget)

        # layout config of whole widget
        self.setLayout(QVBoxLayout())
        self.layout().addLayout(list_view_layout)
        self.layout().addWidget(self._cursor_info_panel)
        self.layout().addWidget(self._unity_info_panel)

    def setModel(self, model):
        """Set model of the viewer."""
        if isinstance(model, QAbstractListModel):
            self._model = model
            self._init_gui()
            self._list_view.setModel(model)
            self._create_actions()
        else:
            raise ValueError('Input must be a ListModel!')

    def _create_actions(self):
        """Create several necessay actions."""
        # When select one item, display specific parameters
        self._list_view.selectionModel().currentChanged.connect(
                                            self._disp_current_para)
        # When select one item, display its undo/redo settings
        self._list_view.selectionModel().currentChanged.connect(
                self.current_changed)
        self._list_view.selectionModel().currentChanged.connect(
                self.update_xyzvl)
        
        # When dataset changed, refresh display.
        self._model.dataChanged.connect(self._disp_current_para)

        # When add new item, refresh display.
        self._model.rowsInserted.connect(self._disp_current_para)
        
        # When remove new item, refresh display.
        self._model.rowsRemoved.connect(self._disp_current_para)

        # When layout changed, refresh display.
        self._model.layoutChanged.connect(self._disp_current_para)

        # When crosshair position changed, refresh coordinate display
        self._model.cross_pos_changed.connect(self.update_xyzvl)

        # When time point changed, refresh coordinate display.
        self._model.time_changed.connect(self.update_xyzvl)
        self._model.time_changed.connect(self.current_changed)

        # Config setting actions
        self._view_min.editingFinished.connect(self._set_view_min)
        self._view_max.editingFinished.connect(self._set_view_max)
        self._colormap.currentIndexChanged.connect(self._set_colormap)
        self._visibility.sliderReleased.connect(self._set_alpha)
        self._up_button.clicked.connect(self._up_action)
        self._down_button.clicked.connect(self._down_action)
        self._volume_index_spinbox.setKeyboardTracking(False)
        self._volume_index_spinbox.valueChanged.connect(self._set_time_point)
        # set voxel ijk position
        self._coord_x.valueChanged.connect(self.set_cross_pos)
        self._coord_y.valueChanged.connect(self.set_cross_pos)
        self._coord_z.valueChanged.connect(self.set_cross_pos)
        # set RAS position
        self._space_x.editingFinished.connect(self.set_space_pos)
        self._space_y.editingFinished.connect(self.set_space_pos)
        self._space_z.editingFinished.connect(self.set_space_pos)

    def _set_time_point(self):
        """Set time point for model."""
        tpoint = self._volume_index_spinbox.value()
        self._model.set_time_point(tpoint)

    def _disp_current_para(self):
        """Display current model's parameters."""
        index = self._list_view.currentIndex()

        if index.row() != -1:
            # set up status of up/down button
            if index.row() == 0:
                self._up_button.setEnabled(False)
            else:
                self._up_button.setEnabled(True)
            if index.row() == (self._model.rowCount() - 1):
                self._down_button.setEnabled(False)
            else:
                self._down_button.setEnabled(True)

            # min/max value
            self._view_min.setText(str(self._model.data(index, Qt.UserRole)))
            self._view_min.setCursorPosition(0)
            self._view_max.setText(str(self._model.data(index, Qt.UserRole + 1)))
            self._view_max.setCursorPosition(0)
        
            # colormap combo box setting
            cur_colormap = self._model.data(index, Qt.UserRole + 3)
            if isinstance(cur_colormap, LabelConfig):
                cur_colormap = cur_colormap.get_name()
            idx = self._colormap.findText(cur_colormap)
            self._colormap.setCurrentIndex(idx)
        
            # alpha slider setting
            current_alpha = self._model.data(index, Qt.UserRole + 2) * \
                    100 / 255
            self._visibility.setValue(current_alpha)

            # time point setting
            if self._model.data(index, Qt.UserRole + 8):
                self._volume_index_spinbox.setEnabled(True)
                self._volume_index_spinbox.setRange(0, 
                        self._model.data(index, Qt.UserRole + 10) - 1)
                time_point = self._model.data(index, Qt.UserRole + 9)
                if not time_point == self._volume_index_spinbox.value():
                    self._volume_index_spinbox.setValue(time_point)
            else:
                self._volume_index_spinbox.setEnabled(False)

            self._list_view.setFocus()

            # Set current index
            self._model.setCurrentIndex(self._list_view.currentIndex())
            self._model.setSelectedIndexes()
        
    def _set_view_min(self):
        """Set current selected item's view_min value."""
        index = self._list_view.currentIndex()
        value = self._view_min.text()
        if value == '':
            self._view_min.setText(str(self._model.data(index, Qt.UserRole + 12)))
            self._view_min.setCursorPosition(0)
        else:
            self._model.setData(index, value, role=Qt.UserRole)

    def _set_view_max(self):
        """Set current selected item's view_max value."""
        index = self._list_view.currentIndex()
        value = self._view_max.text()
        if value == '':
            self._view_max.setText(str(self._model.data(index, Qt.UserRole + 13)))
            self._view_max.setCursorPosition(0)
        else:
            self._model.setData(index, value, role=Qt.UserRole + 1)

    def _set_colormap(self):
        """Set colormap of current selected item."""
        index = self._list_view.currentIndex()
        value = self._colormap.currentText()
        builtin_len = len(self.builtin_colormap)
        row = self._colormap.currentIndex()
        if row >= builtin_len:
            value = self.label_config_center.get_label_config(row - builtin_len)
        self._model.setData(index, value, role=Qt.UserRole + 3)

    def _set_alpha(self):
        """Set alpha value of current selected item."""
        index = self._list_view.currentIndex()
        value = self._visibility.value() * 255 / 100
        self._model.setData(index, value, role=Qt.UserRole + 2)

    def _up_action(self):
        """Move selected item up for one step."""
        index = self._list_view.currentIndex()
        self._model.moveUp(index.row())
        index = self._list_view.currentIndex()
        if index.row() == 0:
            self._up_button.setEnabled(False)
        else:
            self._up_button.setEnabled(True)
        if index.row() == (self._model.rowCount() - 1):
            self._down_button.setEnabled(False)
        else:
            self._down_button.setEnabled(True)
        self._list_view.setFocus()

    def _down_action(self):
        """Move selected item down for one step."""
        index = self._list_view.currentIndex()
        self._model.moveDown(index.row())
        index = self._list_view.currentIndex()
        if index.row() == 0:
            self._up_button.setEnabled(False)
        else:
            self._up_button.setEnabled(True)
        if index.row() == (self._model.rowCount() - 1):
            self._down_button.setEnabled(False)
        else:
            self._down_button.setEnabled(True)
        self._list_view.setFocus()

    def currentRow(self):
        """Return the row of current selected item."""
        return self._list_view.currentIndex().row()

    def setCurrentIndex(self, index):
        """Set selected item."""
        self._list_view.setCurrentIndex(index)

    def update_xyzvl(self):
        """Update the information of crosshair position."""
        # disable signal connection when value changed
        self._coord_x.valueChanged.disconnect()
        self._coord_y.valueChanged.disconnect()
        self._coord_z.valueChanged.disconnect()

        xyz = self._model.get_cross_pos()
        self._coord_x.setValue(int(xyz[0]))
        self._coord_y.setValue(int(xyz[1]))
        self._coord_z.setValue(int(xyz[2]))
        value = self._model.get_current_value([xyz[0], xyz[1], xyz[2]])
        self._coord_value.setText(str(value))
        self._coord_value.setCursorPosition(0)
        space_xyz = self._model.get_space_pos()
        self._space_x.setText(str(around(space_xyz[0], decimals=2)))
        self._space_y.setText(str(around(space_xyz[1], decimals=2)))
        self._space_z.setText(str(around(space_xyz[2], decimals=2)))
        # self._coord_label.setText(self._model.get_current_value_label(value))

        # resume signal connection
        self._coord_x.valueChanged.connect(self.set_cross_pos)
        self._coord_y.valueChanged.connect(self.set_cross_pos)
        self._coord_z.valueChanged.connect(self.set_cross_pos)

    def set_cross_pos(self):
        """Set position of crosshair."""
        new_coord = [int(self._coord_x.value()),
                     int(self._coord_y.value()),
                     int(self._coord_z.value())]
        self._model.set_cross_pos(new_coord)

    def set_space_pos(self):
        """Set RAS position."""
        space_xyz = self._model.get_space_pos()
        try:
            space_x = float(self._space_x.text())
        except:
            space_x = space_xyz[0]
            self._space_x.setText(str(space_xyz[0]))
        try:
            space_y = float(self._space_y.text())
        except:
            space_y = space_xyz[1]
            self._space_y.setText(str(space_xyz[1]))
        try:
            space_z = float(self._space_z.text())
        except:
            space_z = space_xyz[2]
            self._space_z.setText(str(space_xyz[2]))

        new_coord = [space_x, space_y, space_z]
        if not array_equal(new_coord, space_xyz):
            self._model.set_space_pos(new_coord)

