alert 'Hello!'

$ ->
    $('#released_on') # this lne finds the date input field based on the ID.
    .datepicker( changeYear: true, yearRange: '1940:2000' ) # this calls the datepicker() method to add the relevant templated functionality and specifies a few personalisations.