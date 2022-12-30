class Filter{
  ValueInFilterField idIn = ValueInFilterField(fieldName: "id__in");
  Filter();
  String getFilterStr(){
    return "";
  }
}

enum FilterFieldType {
  bool,
  str,
  list,
  valueIn
}

class FilterField {
  String _labelText = "";
  String _hintText = "";
  String _fieldName = "";
  FilterFieldType _type = FilterFieldType.str;

  FilterField(
      {
        labelText = "",
        hintText = "",
        required fieldName,
        required type,
      })
  {
    _labelText = labelText;
    _hintText = hintText;
    _fieldName = fieldName;
    _type = type;
  }
  get getLabelText{ return _labelText; }
  get getHintText{ return _hintText; }
  get getFieldName{ return _fieldName; }
  get getType { return _type; }

  get getHeader{
    return "";
  }
}

class TextFilterField extends FilterField{
  String value = "";

  TextFilterField({
    labelText = "",
    hintText = "",
    required fieldName,

  }):super(labelText: labelText, hintText: hintText,fieldName:fieldName, type: FilterFieldType.str);

  @override
  get getHeader{
    String filterStr = "";
    try{
      DateTime date = DateTime.parse(value);
      filterStr = "$_fieldName=${date.toUtc()}&";
    }catch(e){

      filterStr = "$_fieldName=$value&";
    }
    return filterStr;
  }
}

class BooleanFilterField extends FilterField{
  bool? value ;

  BooleanFilterField({
    labelText = "",
    hintText = "",
    required fieldName,
  }):super(labelText: labelText, hintText: hintText,fieldName:fieldName, type: FilterFieldType.bool);

  @override
  get getHeader{
    return "$_fieldName=$getValue&";
  }
  get getValue{
    dynamic value = (this.value == null)? "unknown": (this.value!)? "true" : "false";
    return value;
  }

  get getChoice{
    dynamic value = (this.value == null)? "Ambos": (this.value!)? "Si" : "No";
    return value;
  }
}

class ListFilterField extends FilterField{
  List values = [];

  ListFilterField({
    labelText = "",
    hintText = "",
    required fieldName,
  }):super(labelText: labelText, hintText: hintText,fieldName:fieldName, type: FilterFieldType.list);

  @override
  get getHeader{
    String str = "";
    for (var value in values){
      str += "$_fieldName=$value&";
    }
    return str;
  }
}

class ValueInFilterField extends FilterField{
  List values = [];

  ValueInFilterField({
    labelText = "",
    hintText = "",
    required fieldName,
  }):super(labelText: labelText, hintText: hintText,fieldName:fieldName, type: FilterFieldType.valueIn);

  @override
  get getHeader{
    String str = "";
    if (values.length > 0) {
      str = "$_fieldName=";
      for (var value in values) {
        str += "$value,";
      }
      str += "&";
    }
    return str;
  }
}
