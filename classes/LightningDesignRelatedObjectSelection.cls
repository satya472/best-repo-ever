/**
 * Created by jens.becker on 01.06.18.
 */

global class LightningDesignRelatedObjectSelection extends VisualEditor.DynamicPickList{

    VisualEditor.DesignTimePageContext context;

    global LightningDesignRelatedObjectSelection(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('-Select-', '-Select-');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        string objName = context.entityName;

        List<Schema.ChildRelationship>  ChildRelations
                = Schema.getGlobalDescribe().get(objName).getDescribe().getChildRelationships();


        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();

        myValues.addRow(getDefaultValue());
        //Schema.describeSObjects().
        for(Schema.ChildRelationship obj : ChildRelations){
            Schema.DescribeSObjectResult tmp = obj.childSObject.getDescribe();

            if(tmp.custom) {
                VisualEditor.DataRow tmpVal = new VisualEditor.DataRow(tmp.name, tmp.localName);
                myValues.addRow(tmpVal);
            }
        }
        return myValues;
    }
}