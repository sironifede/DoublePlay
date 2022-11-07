class Filter{
  Filter();
  String getFilterStr(){
    return "";
  }
}

enum FilterFieldType {
  bool,
  str
}

class FilterField {
  String _labelText = "";
  String _hintText = "";
  String _fieldName = "";
  FilterFieldType _type = FilterFieldType.str;

  FilterField(
      {
        required labelText,
        required hintText,
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

  get getValue{
    return "";
  }
}

class TextFilterField extends FilterField{
  String value = "";

  TextFilterField({
    required labelText,
    required hintText,
    required fieldName,

  }):super(labelText: labelText, hintText: hintText,fieldName:fieldName, type: FilterFieldType.str);

  @override
  get getValue{
    return value;
  }
}

class BooleanFilterField extends FilterField{
  bool? value ;

  BooleanFilterField({
    required labelText,
    required hintText,
    required fieldName,
  }):super(labelText: labelText, hintText: hintText,fieldName:fieldName, type: FilterFieldType.bool);

  @override
  get getValue{
    dynamic value = (this.value == null)? "unknown": (this.value!)? "true" : "false";
    return value;
  }

  get getChoice{
    dynamic value = (this.value == null)? "Ambos": (this.value!)? "Si" : "No";
    return value;
  }
}