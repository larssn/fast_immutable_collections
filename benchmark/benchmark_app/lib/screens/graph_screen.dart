import "../widgets/bar_chart.dart";
import "package:flutter/material.dart";
import "package:fast_immutable_collections_benchmarks/fast_immutable_collections_benchmarks.dart";
import "package:intl/intl.dart";

class GraphScreen extends StatefulWidget {
  final String title;
  final List<RecordsTable> tables;

  const GraphScreen({@required this.title, @required this.tables});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  int _currentTableIndex;
  List<BottomNavigationBarItem> _bottomItems;

  /// We will need to add an artificial button to the bottom bar if there's only one benchmark,
  /// since it requires at least 2 items.
  bool _onlyOneBenchmark;
  bool _stacked;

  final Map<String, bool> _filters = {};

  RecordsTable get _currentTable => _currentTableIndex >= widget.tables.length
      ? widget.tables.last
      : widget.tables[_currentTableIndex];

  final NumberFormat formatter = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    _onlyOneBenchmark = false;
    _stacked = false;
    _currentTableIndex = 0;
    _currentTable.rowNames.forEach((String rowName) => _filters.addAll({rowName: true}));

    super.initState();

    _bottomItems = <BottomNavigationBarItem>[
      for (int i = 0; i < widget.tables.length; i++)
        BottomNavigationBarItem(
          icon: Text(
            "Size\n${formatter.format(widget.tables[i].config.size)}",
            style: TextStyle(fontSize: 17),
            textAlign: TextAlign.center,
          ),
          label: "",
        ),
    ];
    if (_bottomItems.length == 1) {
      _onlyOneBenchmark = true;
      _bottomItems.add(
        BottomNavigationBarItem(
          icon: Icon(Icons.arrow_back),
          label: "Go back",
        ),
      );
    } else if (_bottomItems.length > 1) {
      _bottomItems.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.table_rows),
          label: "All",
        ),
      );
    }
  }

  void _onTap(int index) => setState(() {
        if (_onlyOneBenchmark && index == 1) {
          Navigator.of(context).pop();
        } else if (index == widget.tables.length) {
          _stacked = true;
          _currentTableIndex = index;
        } else {
          _stacked = false;
          _currentTableIndex = index;
        }
      });

  @override
  Widget build(_) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} Benchmark Graph Results"),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  hint: Text(
                    "Filter",
                    style: TextStyle(fontSize: 20),
                  ),
                  items: _filters.keys
                      .map<DropdownMenuItem<String>>(
                        (String filter) => DropdownMenuItem<String>(
                          value: filter,
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                value: _filters[filter],
                                onChanged: (bool value) {},
                              ),
                              Text(
                                filter,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (String newFilter) =>
                      setState(() => _filters.update(newFilter, (bool value) => !value)),
                ),
              ],
            ),
            Container(
              height: 500,
              child: _stacked
                  ? StackedBarChart(recordsTables: _filterAllNTimes(widget.tables))
                  : BarChart(recordsTable: _filterNTimes(_currentTable)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        items: _bottomItems,
        onTap: _onTap,
        currentIndex: _currentTableIndex,
      ),
    );
  }

  List<RecordsTable> _filterAllNTimes(List<RecordsTable> tables) {
    final List<RecordsTable> filteredTables = [];
    tables.forEach((RecordsTable table) => filteredTables.add(_filterNTimes(table)));
    return filteredTables;
  }

  RecordsTable _filterNTimes(RecordsTable table) {
    _filters.forEach((String filterName, bool shouldNotFilter) {
      if (!shouldNotFilter) table = table.filter(filterName);
    });
    return table;
  }
}
