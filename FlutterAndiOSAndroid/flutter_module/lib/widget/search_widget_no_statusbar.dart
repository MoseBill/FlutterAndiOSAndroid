import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

typedef void OnValueChanged(String value);
typedef void OnSearchBtnClick(String value);

class SearchWidgetNoStstusbar extends StatefulWidget {
  final String textValue;

  ///{@macro 输入框变化,回调时间,默认500毫秒}
  final int textChangeDuration;
  final String hintText;
  final double textFiledHeight;
  final TextEditingController controller;
  final OnValueChanged onValueChangedCallBack;
  final OnSearchBtnClick onSearchBtnClick;

  SearchWidgetNoStstusbar(
      {this.textValue,
      this.textFiledHeight = 48.0,
      @required this.controller,
      this.hintText,
      this.textChangeDuration = 500,
      this.onSearchBtnClick,
      this.onValueChangedCallBack});

  @override
  _SearchGoodsState createState() => _SearchGoodsState();
}

class _SearchGoodsState extends State<SearchWidgetNoStstusbar> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) {
      throw Exception('TextEditingController 没有初始化');
    }
    return Container(
      height: widget.textFiledHeight,
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey[100]))),
      child: Row(
        children: <Widget>[
          GestureDetector(
            child: Container(
              height: widget.textFiledHeight,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Container(
              height: widget.textFiledHeight,
              margin: EdgeInsets.symmetric(vertical: 7),
              padding: EdgeInsets.only(right: 5),
              decoration: new BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[200], width: 0.1),
                  borderRadius: new BorderRadius.circular(5.0)),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      Icons.search,
                      size: 22,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      style: TextStyle(textBaseline: TextBaseline.alphabetic, fontSize: 16),
                      decoration: InputDecoration(
                          hintText: TextUtil.isEmpty(widget.hintText) ? '' : widget.hintText,
                          contentPadding: EdgeInsets.only(bottom: 15),
                          border: InputBorder.none),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (text) {
                        //回车按钮
                        setState(() {
                          if (widget.onSearchBtnClick != null && this.text.isNotEmpty) {
                            widget.onSearchBtnClick(text);
                          }
                        });
                      },
                      maxLines: 1,
                      onChanged: (textValue) {
                        _startTimer(textValue);
                      },
                      controller: widget.controller,
                    ),
                  ),
                  Container(
                    child: GestureDetector(
                      child: TextUtil.isEmpty(text)
                          ? Container()
                          : Icon(
                              Icons.cancel,
                              size: 20,
                              color: Colors.grey,
                            ),
                      onTap: () {
                        widget.controller.clear();
                        setState(() {
                          text = '';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 70,
            height: widget.textFiledHeight,
            margin: EdgeInsets.symmetric(vertical: 7),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: RaisedButton(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  if (widget.onSearchBtnClick != null && text.isNotEmpty) {
                    widget.onSearchBtnClick(text);
                  }
                },
                child: Text(
                  '搜索',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                color: Colors.transparent,
                highlightColor: Colors.grey[200],
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Timer timer;

  _startTimer(String value) {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(milliseconds: widget.textChangeDuration), () {
      setState(() {
        this.text = value.trim();
        if (widget.onValueChangedCallBack != null) {
          widget.onValueChangedCallBack(text);
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }
}
