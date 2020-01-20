/**
 * Created by jens.becker on 01.06.18.
 */

global class LightningDesignFieldSelection extends VisualEditor.DynamicPickList{

    VisualEditor.DesignTimePageContext context;



    global LightningDesignFieldSelection(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('none', 'none');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        string objName = context.entityName;

        Map<String, Schema.SObjectField> objectFields
                = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();


        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();

        for(Schema.SObjectField flds :objectFields.values()){
            VisualEditor.DataRow tmpVal = new VisualEditor.DataRow(flds.getDescribe().getLabel(),flds.getDescribe().getLocalName());
            myValues.addRow(tmpVal);
        }
        return myValues;
    }
}