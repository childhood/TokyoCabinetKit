var memos = [
  { title: 'A', content: 'AAA' },
  { title: 'B', content: 'BBB' },
  { title: 'C', content: 'CCC' }
];

Ti.UI.setBackgroundColor('#fff');

mainWindow = Ti.UI.createWindow();

win = Ti.UI.createWindow({
  title: 'Memo'
});

navGroup = Ti.UI.iPhone.createNavigationGroup({
  window: win
});
mainWindow.add(navGroup);

var editB = Ti.UI.createButton({
  systemButton: Ti.UI.iPhone.SystemButton.BORDERED,
  title: 'Edit'
});
win.setLeftNavButton(editB);

var addB = Ti.UI.createButton({
  systemButton: Ti.UI.iPhone.SystemButton.BORDERED,
  title: 'Add'
});
win.setRightNavButton(addB);

addB.addEventListener('click', function() {
  var editor = Ti.UI.createWindow({
    title: 'Add Memo',
    url: 'editor.js'
  });

  var cancel = Ti.UI.createButton({
    systemButton: Ti.UI.iPhone.SystemButton.BORDERED,
    title: 'Cancel'
  });
  cancel.addEventListener('click', function() {
    editor.close();
  });
  editor.setLeftNavButton(cancel);

  var done = Ti.UI.createButton({
    systemButton: Ti.UI.iPhone.SystemButton.DONE
  });
  done.addEventListener('click', function() {
    editor.close();
  });
  editor.setRightNavButton(done);

  editor.open({
    modal: true,
    modalTransitionStyle: Ti.UI.iPhone.MODAL_TRANSITION_STYLE_COVER_VERTICAL,
    modalStyle: Ti.UI.iPhone.MODAL_PRESENTATION_FULLSCREEN,
    navBarHidden: false
  });
});

var table = Ti.UI.createTableView({
  data: memos.map(function(m) {
    if ((m.title || "").length == 0) {
      m.title = (m.content || "").substring(0, 20);
    }
    m.hasChild = true;
    return m;
  })
});

table.addEventListener('click', function(e) {
  var editor = Ti.UI.createWindow({
    title: 'Edit Memo',
    url: 'editor.js',
    memo: memos[e.index]
  });

  var done = Ti.UI.createButton({
    systemButton: Ti.UI.iPhone.SystemButton.DONE
  });
  done.addEventListener('click', function() {
    navGroup.close(editor, { animated: true });
  });
  editor.setRightNavButton(done);

  navGroup.open(editor, { animated: true });
});

win.add(table);

mainWindow.open();

var TC = require('com.valleyport.ti.tokyocabinet');
Ti.API.debug("module is => " + TC);

//Ti.API.info("call: " + TC.example());
//Ti.API.info("prop: " + TC.exampleProp);

var tdb = TC.createTableDB();
Ti.API.info("tdb: " + tdb);

tdb.open("memo.tct");
Ti.API.info("opened");
//tdb.close();

//tdb = TC.createTableDB("memo.tct");
//Ti.API.info("tdb: " + tdb);
//tdb.close();
//
//tdb = TC.createTableDB("memo.tct", TC.TDBOWRITER, TC.TDBOCREAT);
//Ti.API.info("tdb: " + tdb);
