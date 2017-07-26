# Stroom Quick-Start Guide - Dashboards

Create a new dashboard the same way you create anything else

![New dashboard](images/001_dashboard_new.png)

On the query pane click the settings (![Dashboard settings button](images/007_dashboard_settings_button.png)) button on the top right of the panel.

Choose the index you just created as your data source.

![New dashboard](images/002_dashboard_query_settings.png)

Now add a term to the query to get a handle on the data

![Dashboard query add term](images/002_dashboard_query_add_term.png)

For our simple example we’re using a wildcard that captures all documents with an Id set.

![Dashboard query edit term](images/003_dashboard_query_edit_term.png)

Then in the table panel we can add the fields we are interested in, in this case we wanted to sort the application field and count how many time the application name appears.

![Dashboard table fields](images/004_dashboard_table_fields.png)

Start the query and we should get this

![Dashboard table](images/005_dashboard_table.png)

Then we can add an element from the top again and this time use visualisation

![Dashboard add visualisation](images/006_dashboard_add_visualisation.png)

In the visualisation panel that has been added to the bottom, click the settings (![Dashboard settings button](images/007_dashboard_settings_button.png)) button on the top right of the panel.

In our example we have used the Bubble visualisation

![Visualisation settings - basic](images/008_visualisation_settings_basic.png)

![Visualisation settings data](images/009_visualisation_settings_data.png)

Which gives us this visualisation when the query is executed

![Bubble visualisation](images/010_visualisation_bubbles.png)

Where you can hover over elements and get a summary of that representation.

![Bubble visualisation legends](images/011_visualisation_bubbles_legend.png)
