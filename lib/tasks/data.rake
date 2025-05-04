require 'csv'

namespace :data do
  desc 'Load team members from a CSV file. Usage: rake "data:load[path/to/file.csv,send_invitations]" - send_invitations is optional (default: false)'
  task :load, [:csv_file, :send_invitations] => :environment do |t, args|
    if args[:csv_file].nil?
      puts "Error: Missing CSV file path."
      puts "Usage: rake \"data:load[path/to/file.csv,send_invitations]\""
      puts "  - send_invitations: Optional. Set to 'true' to send invitation emails (default: false)"
      exit 1
    end
    
    # Determine whether to send invitation emails (default: false)
    send_invitations = args[:send_invitations].to_s.downcase == 'true'
    puts "Invitation emails will #{send_invitations ? '' : 'NOT '} be sent."

    unless File.exist?(args[:csv_file])
      puts "Error: CSV file not found: #{args[:csv_file]}"
      exit 1
    end

    puts "Loading data from #{args[:csv_file]}..."
    
    # Track current team and description for inheritance
    current_team = nil
    current_description = nil
    
    # Track created teams to avoid duplicates
    teams_cache = {}
    
    # Read and process the CSV file
    row_count = 0
    team_member_count = 0
    
    CSV.foreach(args[:csv_file], headers: true) do |row|
      row_count += 1
      
      # Get team name, inheriting from previous row if empty
      team_name = row['Team'].to_s.strip
      if team_name.empty?
        if current_team.nil?
          puts "Error: Row #{row_count} has no team and there is no previous team to inherit from"
          next
        end
      else
        current_team = team_name
      end
      
      # Get description, inheriting from previous row if empty
      description = nil
      if row.headers.include?('Description')
        description = row['Description'].to_s.strip
        if description.empty?
          description = current_description
        else
          current_description = description
        end
      end
      
      # Get user name and email
      user_name = row['Name'].to_s.strip
      user_email = row['Email'].to_s.strip
      
      if user_name.empty? || user_email.empty?
        puts "Warning: Row #{row_count} has empty name or email, skipping"
        next
      end
      
      # Find or create the team
      team = teams_cache[current_team]
      if team.nil?
        team = Team.find_or_create_by(name: current_team) do |t|
          t.description = description
        end
        
        # Update description if the team already existed but description changed
        if team.persisted? && team.description != description && !description.nil?
          team.update(description: description)
        end
        
        teams_cache[current_team] = team
        puts "Team: #{team.name} - #{team.description.present? ? team.description : 'No description'}"
      elsif !description.nil? && team.description != description
        # Update the team description if it's changed in a later row
        team.update(description: description)
        teams_cache[current_team] = team
        puts "Updated Team: #{team.name} - #{description}"
      end
      
      # Create the user as a team member without sending invitations
      begin
        # Try to find an existing user
        user = User.find_by(email: user_email)
        
        if user
          # Update existing user if necessary
          if user.user_type != 'team_member' || user.team_id != team.id
            user.user_type = :team_member
            user.team = team
            user.save(validate: false)
            puts "  Updated existing user: #{user.name} (#{user.email}) - now a member of #{team.name}"
          else
            puts "  User already exists: #{user.name} (#{user.email})"
          end
        else
          # Create a new user
          user = User.new(
            name: user_name,
            email: user_email,
            user_type: :team_member,
            team: team,
            password: SecureRandom.hex(12) # This will be reset when they accept the invitation
          )
          
          if send_invitations
            # Let invitations be sent normally
            puts "  Sending invitation email to: #{user_email}"
          else
            # Skip sending invitation emails
            old_method = User.instance_method(:send_invitation_email) rescue nil
            
            if old_method
              User.define_method(:send_invitation_email) { true } # do nothing for now
            end
            
            # Set any devise_invitable attributes directly if available
            user.skip_invitation = true if user.respond_to?(:skip_invitation=)
          end
          
          if user.save(validate: false)
            team_member_count += 1
            puts "  Added team member: #{user.name} (#{user.email})"
          else
            puts "  Error creating team member: #{user.name} (#{user.email}) - #{user.errors.full_messages.join(', ')}"
          end
          
          # Restore the original method if we patched it
          if !send_invitations && defined?(old_method) && old_method
            User.define_method(:send_invitation_email, old_method)
          end
        end
      rescue => e
        puts "  Error processing user: #{user_name} (#{user_email}) - #{e.message}"
      end
    end
    
    puts "\nImport complete!"
    puts "Processed #{row_count} rows"
    puts "Created/updated #{teams_cache.size} teams"
    puts "Created/updated #{team_member_count} team members"
    puts "Invitation emails were #{send_invitations ? '' : 'NOT '}sent"
    
    unless send_invitations
      puts "\nTo send invitation emails to these users later, you can run:"
      puts "  rake data:send_invitations"
    end
  end
  
  desc 'Send invitation emails to all users who have not logged in yet'
  task :send_invitations => :environment do
    non_active_users = User.where(last_login_at: nil)
    count = 0
    
    puts "Found #{non_active_users.count} users who have never logged in."
    puts "Sending invitation emails..."
    
    non_active_users.find_each do |user|
      begin
        # Skip if the user doesn't have an email
        next if user.email.blank?
        
        # Use the devise_invitable method to send an invitation
        if user.invite!
          count += 1
          puts "Sent invitation to: #{user.name} (#{user.email})"
        end
      rescue => e
        puts "Error sending invitation to #{user.name} (#{user.email}): #{e.message}"
      end
    end
    
    puts "Sent #{count} invitation emails."
  end
end