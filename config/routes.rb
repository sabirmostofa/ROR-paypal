RubySdk::Application.routes.draw do
	
  get "threedsecure/threedsecure/begin"
  get "threedsecure/threedsecure/pay"
  get "threedsecure/threedsecure/do_DCC3D"
  get "threedsecure/threedsecure/thanks"

  get "billoutamt/begin"
  get "billoutamt/do_billamt"
  get "billoutamt/billdetails"

  get "manageprofile/begin"
   get "manageprofile/change_rpdetails"
  get "manageprofile/changedProfile"

  get "rpdetails/begin"
  get "rpdetails/RPdetails"
  get "rpdetails/get_rpdetails"
  get "rpdetails/details"

  get "rpprofile/begin"
  get "rpprofile/do_rpprofile"
  get "rpprofile/thanks"

  get "masspay/mass_pay"
  get "masspay/do_mass_pay"
  get "masspay/thanks"

  get "recurringpayment/begin"

  get "reauth/get_input"
  get "reauth/do_reauth"
  get "reauth/thanks"

  get "refund/get_input"
  get "refund/do_refund"
  get "refund/status"

  get "ts/get_input"
  get "ts/do_search"
  get "ts/show"

  get "getbalance/get_input"
  get "getbalance/get_balance"
  get "getbalance/thanks"

  get "gtd/search"
  get "gtd/get_transaction_details"
  get "gtd/transaction_details"

  get "dovoid/get_input"
  get "dovoid/do_void"
  get "dovoid/thanks"

  get "docapture/get_input"
  get "docapture/do_capture"
  get "docapture/thanks"

  get "doauthorization/get_input"
  get "doauthorization/do_authorization"
  get "doauthorization/thanks"

  get "ec/begin"
  get "ec/buy"
  get "ec/ec_step1"
  get "ec/ec_step2"
  get "ec/ec_step3"
  get "ec/ecdetails"
  get "ec/thanks"

  get "dcc/begin"
  get "dcc/pay"
  get "dcc/thanks"

  get "wppro/index"
  get "wppro/error"
  get "wppro/exception"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  match ':controller(/:action(/:id(.:format)))'
  match ':controller/:action/:id'
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  match 'dcc1' => 'dcc#do_DCC'
  match 'ecstep1' => 'ec#ec_step1'
  match 'ecstep3' => 'ec#ec_step3'
  match 'doAuthorization' => 'doauthorization#do_authorization'
  match 'doCapture' => 'docapture#do_capture'
  match 'doVoid' => 'dovoid#do_void'
  match 'getTransactionDetails' => 'gtd#get_transaction_details'
  match 'getBalance' => 'getbalance#get_balance'
  match 'transactionSearch' => 'ts#do_search'
  match 'doRefund' => 'refund#do_refund'
  match 'doReauth' => 'reauth#do_reauth'
  match 'doMassPay' => 'masspay#do_mass_pay'
  match 'doRpprofile' => 'rpprofile#do_rpprofile'
  match 'doRPdetails' => 'rpdetails#get_rpdetails'
  match 'manageProfile' => 'manageprofile#change_rpdetails'
  match 'billOutAmt' => 'billoutamt#do_billamt'
  match 'threedSecure' => 'threedsecure/threedsecure#do_DCC3D'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "wppro#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
