import { LightningElement, api, track } from 'lwc';


export default class Cep_fileDownload extends LightningElement {

    @api contentVersion;
    @track iconName;
    @track downloadLink;

    connectedCallback(){

        if(this.contentVersion.FileExtension === 'docx'){
            this.iconName = 'doctype:word'
        }else if(this.contentVersion.FileExtension === 'pdf'){
            this.iconName = 'doctype:pdf'
        }else if(this.contentVersion.FileExtension === 'pptx'){
            this.iconName = 'doctype:ppt'
        }else if(this.contentVersion.FileExtension === 'xlsx'){
            this.iconName = 'doctype:excel'
        }else if(this.contentVersion.FileExtension === 'txt'){
            this.iconName = 'doctype:txt'
        }else if(this.contentVersion.FileExtension === 'jpg' || this.contentVersion.FileExtension === 'png' || this.contentVersion.FileExtension === 'jpg'){
            this.iconName = 'doctype:image'
        }else if(this.contentVersion.FileExtension === 'zip'){
            this.iconName = 'doctype:zip'
        }else if(this.contentVersion.FileExtension === 'exe'){
            this.iconName = 'doctype:exe'
        }else{
            this.iconName = 'doctype:image'
        }

        this.downloadLink = '/JEP/sfc/servlet.shepherd/version/download/'+this.contentVersion.Id;
        

    }

}