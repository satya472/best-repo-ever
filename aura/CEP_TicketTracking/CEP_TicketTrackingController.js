( {
  doInit: function ( component, event, helper ) {
    let rec = [ {
        'Id': '1',
        'ticketNumber': '123',
        'AccountName': 'Testing Account',
        'contactName': 'Test Contact',
        'subject': 'The Content mentioned here is just for testing',
        'status': 'completed',
        'ticketType': 'Unit Related',
        'relatedUnit': 'Related Unit Details',
        'createdDate': '2019-01-10',
        'description': 'Test Description'
      },
      {
        'Id': '2',
        'ticketNumber': '456',
        'AccountName': 'Testing Account',
        'contactName': 'Test Contact',
        'subject': 'The Content mentioned here is just for testing',
        'status': 'In Progress',
        'ticketType': 'Unit Related',
        'relatedUnit': 'Unit',
        'createdDate': '2019-01-11',
        'description': 'Test Description'
      },
      {
        'Id': '3',
        'ticketNumber': '789',
        'AccountName': 'Testing Account',
        'contactName': 'Test Contact',
        'subject': 'The Content mentioned here is just for testing',
        'status': 'completed',
        'ticketType': 'Portal Support',
        'relatedUnit': 'Details',
        'createdDate': '2019-01-12',
        'description': 'Test Description'
      }

    ];

    component.set( "v.filteredList", rec );
    component.set( "v.fullList", rec );

    component.set( "v.typeList",
      [ {
          'label': 'Portal Support',
          'value': 'Portal Support'
        },
        {
          'label': 'Unit Related',
          'value': 'Unit Related'
        },
        {
          'label': 'myOutages',
          'value': 'myOutages'
        },
      ]
    );

    component.set( "v.statusList",
      [ {
          'label': 'In Progress',
          'value': 'In Progress'
        },
        {
          'label': 'Completed',
          'value': 'Completed'
        },
        {
          'label': 'Recommendation Provided',
          'value': 'Recommendation Provided'
        },
      ]
    );

  },

  filterChange: function ( component, event, helper ) {
    let eleName = event.getSource().get( "v.name" );
    let eleValue = event.getSource().get( "v.value" );
    let existingFilters = component.get( "v.filterPillList" );

    let filterExists = existingFilters.find( ( element ) => {
      return element.name === eleName;
    } );

    if ( $A.util.isEmpty( filterExists ) ) {
      existingFilters.push( {
        'label': eleName,
        'name': eleName
      } );

      component.set( "v.filterPillList", existingFilters );
    }

    helper.filterRecords( component, event, helper );
  },
  removeFilter: function ( component, event, helper ) {

    let name = event.getParam( "item" ).name;
    let items = component.get( 'v.filterPillList' );
    let itemindex = event.getParam( "index" );
    console.log(items == component.get('v.filterPillList'));
    component.get( 'v.filterPillList' ).splice( itemindex, 1 );
    alert(JSON.stringify(component.get( 'v.filterPillList' )));
  //  component.set( 'v.filterPillList', items );
    if ( name == 'type' ) {
      component.find( "ticketType" ).set( "v.value", '' );
    } else if ( name == 'status' ) {
      component.find( "status" ).set( "v.value", '' );
    } else {
      component.find( "searchTxt" ).set( "v.value", '' );
    }

    helper.filterRecords( component, event, helper );

  },
  showDetails: function ( component, event, helper ) {

    let selId = event.currentTarget.dataset.id;

    let selectedRec = component.get( "v.fullList" ).find( rec => {
      return rec.Id == selId;
    } );

    component.set( "v.selectedTicket", selectedRec );

    component.set( "v.displayDetails", true );

  },
  close: function ( component, event, helper ) {

    component.set( "v.displayDetails", false );

  },
} )