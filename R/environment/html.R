HTML(
  paste0(
    '
  .toggle_filter{background-color:',bg_color,';margin:5px}
  .shiny-bound-input{margin:5px !important}
  .shiny-input-container{margin:5px !important}
  .sidebar {background-color: ',bg_color,';}
  .movement_sidebar_button {background-color: ',bg_color,';}
  .toggle_parameters{background-color:',bg_color,';margin:5px}
  .shiny-input-container{margin:5px !important}
  .fa-filter {color:',detail_color,'}
  .fa-bars {color:',detail_color,'}
  .fa-flask {color:',detail_color,'}
  .fa-database {color:',detail_color,'}
  .fa-sliders-h {color:',detail_color,'}
  .egClass:focus {outline: none !important}
  .js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {
                                                  background: ',detail_color, ';
                                                  border-top: 1px solid ',detail_color, ' ;
                                                  border-bottom: 1px solid ',detail_color, ' ;}
                           .irs-from, .irs-to, .irs-single { background: ',detail_color, ' }
  '
  )
)
