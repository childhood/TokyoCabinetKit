var win = Ti.UI.currentWindow;

var textRow = Ti.UI.createTableViewRow({
  height: 44,
  selectionStyle: Ti.UI.iPhone.TableViewCellSelectionStyle.NONE,
  className: 'control'
});

textRow.add(Ti.UI.createTextField({
  top: 0,
  left: 10,
  width: 250,
  hintText: 'Title',
  borderStyle: Ti.UI.INPUT_BORDERSTYLE_NONE,
  value: win.memo ? win.memo.title : null
}));

var contentRow = Ti.UI.createTableViewRow({
  height: 200,
  selectionStyle: Ti.UI.iPhone.TableViewCellSelectionStyle.NONE,
  className: 'control'
});

contentRow.add(Ti.UI.createTextArea({
  color: '#000000',
  font: { fontSize: 16 },
  height: 190,
  suppressReturn: false,
  value: win.memo ? win.memo.content : null
}));

var data = [ textRow, contentRow ];

var tableView = Ti.UI.createTableView({
  data: data,
  style: Ti.UI.iPhone.TableViewStyle.GROUPED
});

win.add(tableView);
