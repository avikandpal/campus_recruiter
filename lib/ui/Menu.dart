import 'package:flutter/material.dart';
import 'package:flutter_geek_test/model/Category.dart';
import 'package:flutter_geek_test/utils/constants/Colors.dart';
import 'package:flutter_geek_test/utils/spacer/paddings.dart';
import 'package:flutter_geek_test/utils/utils.dart';

// One entry in the multilevel list displayed by this app.
class FilterSections {
  static const All = 0;
  static const Attempted = 1;
  static const Unattempted = 2;
  static const Star = 3;

  /// in negative because what if  categories  have more than the value
  /// lets assume we set this as 4 and categories are 5 and user selects the
  /// 4th category then  problem occurs
  static const CategoryAll = -1;
}

class Entry {
  Entry({
    required this.title,
    required this.id,
    required this.isSelected,
    this.children = const <Entry>[],
  });

  final String title;
  final String id;
  final List<Entry> children;
  bool isSelected;
}

final List<Entry> filterList = <Entry>[
  Entry(title: 'All', id: '1', isSelected: true),
  Entry(title: 'Attempted', id: '2', isSelected: false),
  Entry(title: 'Unattempted', id: '3', isSelected: false),
  Entry(title: 'Starred', id: '4', isSelected: false),
];

List<Category>? categories;
final filterGroupValue = -1;
int selectedFilter = 0;
int selectedCategory = 0;

class CheckBox extends StatefulWidget {
  late bool isShowFilter;
  final Function onFilterApplied;

  CheckBox({this.isShowFilter = false, required this.onFilterApplied});

  @override
  _CheckBoxState createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  bool isAllSelected = true;

  Widget getFilterTitle(String title) {
    return Padding(
      padding: Paddings.all4px,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
              color: appThemeColor,
              fontWeight: FontWeight.w700,
              fontSize: 16.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Paddings.horizontal20px,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              getFilterTitle('Filters'),
              ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: filterList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int i) {
                    return Row(
                      children: <Widget>[
                        Radio(
                          value: i,
                          groupValue: selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              selectedFilter = i;
                            });
                          },
                        ),
                        Text(filterList[i].title),
                      ],
                    );
                  }),
              Container(
                height: 1.0,
                color: Colors.grey,
              ),
              getFilterTitle('Categories'),
              ListView.builder(
                  itemCount: (categories?.length ?? 0) + 1,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (BuildContext context, int i) {
                    return i == 0
                        ? Row(
                            children: <Widget>[
                              Radio(
                                value: i,
                                groupValue: selectedCategory,
                                onChanged: (int? value) {
                                  print("value for all ::: $value");
                                  categories?.forEach((category) {
                                    category.isSelected = false;
                                  });
                                  selectedCategory = value ?? 0;
                                  isAllSelected = true;
                                  setState(() {});
                                },
                              ),
                              Text("All"),
                            ],
                          )
                        : Row(
                            children: <Widget>[
                              Radio(
                                value: i,
                                groupValue: selectedCategory,
                                onChanged: (int? value) {
                                  print("value ::: $value");
                                  isAllSelected = false;
                                  selectCategoryInList((value ?? 0) - 1);
                                  selectedCategory = value ?? 0;
                                  setState(() {});
                                },
                              ),
                              Text(categories?[i - 1].name ?? "-"),
                            ],
                          );
                  }),
              Padding(
                padding: const EdgeInsets.only(
                    left: 40.0, right: 40.0, bottom: 20.0, top: 20),
                child: RoundedActionButton(
                  title: "Apply Filter",
                  fontSize: 15.0,
                  onClick: () {
                    print("Apply filter clicked");
                    widget.isShowFilter = false;
                    widget.onFilterApplied(
                        false,
                        selectedFilter,
                        isAllSelected
                            ? FilterSections.CategoryAll
                            : selectedCategory > 0
                                ? selectedCategory - 1
                                : selectedCategory);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  selectCategoryInList(int index) {
    categories?.forEach((category) {
      category.isSelected = false;
    });
    categories?[index].isSelected = true;
  }
}

class Filter extends StatefulWidget {
  bool isShow;

  final Function onFilterApplied;
  List<Category>? categoryList;
  int? selectedFilter;

  Filter(
    this.categoryList, {
    Key? key,
    required this.onFilterApplied,
    this.isShow = false,
    this.selectedFilter,
  }) : super(key: key);

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  @override
  void initState() {
    super.initState();
    categories = widget.categoryList;
    for (var i = 0; i < (categories?.length ?? 0); i++) {
      if (categories?[i].isSelected ?? false) {
        selectedCategory = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CheckBox(
        isShowFilter: widget.isShow,
        onFilterApplied: widget.onFilterApplied,
      ),
    );
  }
}
