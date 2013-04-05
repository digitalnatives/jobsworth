ActiveAdmin.register Company do
  index do
    selectable_column
    column :logo do |c|
      image_tag("/companies/show_logo/#{c.id}", :height => '50') if c.logo?
    end
    column :name
    column :subdomain
    column :contact_name
    column :contact_email
    column :suppressed_email_addresses
    column :show_wiki
    column :use_billing
    column :use_resources
    default_actions
  end

  show do |c|
    attributes_table do
      row :logo do
        image_tag("/companies/show_logo/#{c.id}") if c.logo?
      end
      row :name
      row :subdomain
      row :contact_name
      row :contact_email
      row :suppressed_email_addresses
      row :show_wiki
      row :use_billing
      row :use_resources
    end
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Details" do
      f.input :name
      f.input :subdomain
      f.input :contact_name
      f.input :contact_email
      f.input :suppressed_email_addresses
      f.input :show_wiki
      f.input :use_billing
      f.input :use_resources
      f.input :logo,
              :as => :file,
              :hint => (f.object.logo? ? f.template.image_tag("/companies/show_logo/#{f.object.id}") : "")
    end
    f.buttons
  end
end
