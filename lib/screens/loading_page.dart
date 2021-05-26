import 'package:hive/hive.dart';
import 'transactions_Page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moneymanagementapp/services/Card_Data.dart';
import 'package:moneymanagementapp/utilities/constants.dart';
import 'package:moneymanagementapp/utilities/cardview.dart';
import 'package:moneymanagementapp/utilities/AddCategoryFAB.dart';
import 'package:moneymanagementapp/utilities/balanceCard.dart';
import 'package:moneymanagementapp/utilities/cardDetails.dart';
import 'package:moneymanagementapp/modals/categoryItems.dart';

List<Box> itemsBox = [];
class LoadingScreen extends StatefulWidget {
  static String id="mainPage";
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {

  ScrollController scrollController;
  ScrollController scrollController2;
  var cardIndex = 0;
  AnimationController animationController;
  AnimationController animationController2;

  Future<List<Box>> _openBox() async {
    await Hive.openBox(itemBoxName);
    return itemsBox;
  }
  @override
  void initState() {
    _openBox();
    scrollController = new ScrollController();
    scrollController2= new ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("WALLET", style: TextStyle(fontSize: 16.0),),
        backgroundColor: Color(0xffE8816D),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(child: Icon(Icons.account_circle),),
          ),
        ],
        elevation: 0.0,
      ),
      floatingActionButton: AddCategoryFAB(),
      backgroundColor: Color(0xffE8816D),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: ListView(
            children: <Widget>[
              BalanceCard(),
              SizedBox(height: 20,),
              Text("Expense", style: kcategoryTextStyle,),
              Container(
                //padding: EdgeInsets.all(8),
                height: 250,
                child: WatchBoxBuilder(
                  box: Hive.box(catBoxName),
                  builder: (context, categoryBox){
                    int totlength=0;
                    Provider.of<CardData>(context).refresh();
                  for(int i=0;i<categoryBox.length;i++){
                    CategoryItem category = categoryBox.values.toList()[i];
                    if(category.transactionType == "Expense"){
                      totlength++;
                    }
                  }
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: totlength,
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, position) {
                        for(int i=0;i<categoryBox.length;i++){
                          CategoryItem category = categoryBox.values.toList()[i];
                          if(category.transactionType == "Expense"){
                            CardItemModel item = CardItemModel(category.categoryName, Icons.dashboard_customize, 0,0);
                            Provider.of<CardData>(context,listen: false).cardsList.add(item);
                          }
                        }

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (context){
                              return TransactionsScreen(category: categoryBox.get(Provider.of<CardData>(context,listen: false).cardsList[position].cardTitle),);
                            }));
                            //Provider.of<CardData>(context,listen: false).cardsList[position] = newModel;
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8.0, top: 8.0),
                            child: Card(
                              child: CardDetails(
                                cardList: Provider.of<CardData>(context,listen: false).cardsList,
                                position: position,
                                deleteCallback: (String categoryName, int position){
                                  categoryBox.delete(categoryName);
                                  Provider.of<CardData>(context,listen: false).cardsList.remove(Provider.of<CardData>(context,listen: false).cardsList[position]);
                                },),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              ),
                            ),
                          ),
                          onHorizontalDragEnd: (details) {
                            animationController = AnimationController(duration: Duration(milliseconds: 500), vsync: this,);
                            if(details.velocity.pixelsPerSecond.dx > 0 && cardIndex>0) {
                              cardIndex--;
                            }
                            else if(cardIndex < Provider.of<CardData>(context,listen: false).cardsList.length){
                              cardIndex++;
                            }
                            setState(() {
                              scrollController.animateTo((cardIndex)*256.0, duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
                            });
                            animationController.forward( );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Text("Incomes", style: kcategoryTextStyle,),
              Container(
                //padding: EdgeInsets.all(8),
                height: 250,
                child: WatchBoxBuilder(
                  box: Hive.box(catBoxName),
                  builder: (context, categoryBox){
                    int totlength=0;
                    for(int i=0;i<categoryBox.length;i++){
                      CategoryItem category = categoryBox.values.toList()[i];
                      if(category.transactionType == "Incomes"){
                        totlength++;
                      }
                    }
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      //itemCount: Provider.of<CardData>(context, listen: true).cardsList.length,
                      itemCount: totlength,
                      controller: scrollController2,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, position) {
                        for(int i=0;i<categoryBox.length;i++){
                          CategoryItem category = categoryBox.values.toList()[i];
                          if(category.transactionType == "Incomes"){
                            CardItemModel item = CardItemModel(category.categoryName, Icons.dashboard_customize, 0,0);
                            Provider.of<CardData>(context,listen: false).incomeList.add(item);
                          }
                        }
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (context){
                                  return TransactionsScreen(category: categoryBox.get(Provider.of<CardData>(context,listen: false).incomeList[position].cardTitle),);
                                }));
                            //Provider.of<CardData>(context,listen: false).cardsList[position] = newModel;
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8.0, top: 8.0),
                            child: Card(
                              child: CardDetails(
                                cardList: Provider.of<CardData>(context,listen: false).incomeList,
                                position: position,
                                deleteCallback: (String categoryName, int position){
                                  Provider.of<CardData>(context,listen: false).incomeList.remove(Provider.of<CardData>(context,listen: false).incomeList[position]);
                                  categoryBox.delete(categoryName);
                                },
                                cat: "Incomes",
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              ),
                            ),
                          ),
                          onHorizontalDragEnd: (details) {
                            animationController2 = AnimationController(duration: Duration(milliseconds: 500), vsync: this,);
                            if(details.velocity.pixelsPerSecond.dx > 0 && cardIndex>0) {
                              cardIndex--;
                            }
                            else if(cardIndex < Provider.of<CardData>(context,listen: false).incomeList.length){
                              cardIndex++;
                            }
                            setState(() {
                              scrollController2.animateTo((cardIndex)*256.0, duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
                            });
                            animationController2.forward( );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
