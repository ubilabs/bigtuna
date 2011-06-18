module BigTuna
  class Hooks::Mailer < Hooks::Base
    NAME = "mailer"

    def build_fixed(build, config)
      Sender.delay.build_fixed build, config["recipients"]
    end

    def build_still_fails(build, config)
      Sender.delay.build_still_fails build, config["recipients"]
    end

    def build_failed(build, config)
      Sender.delay.build_failed build, config["recipients"]
    end

    class Sender < ActionMailer::Base
      append_view_path("lib/big_tuna/hooks")
      default :from => "no-reply@ubilabs.net"

      def build_failed(build, recipients)
        @build = build
        @project = @build.project
        recipients = add_recipients recipients
        unless recipients.blank?
          mail(:to => recipients, :subject => "'#{@build.display_name}' in '#{@project.name}' failed") do |format|
            format.text { render "mailer/build_failed" }
          end
        end
      end

      def build_still_fails(build, recipients)
        @build = build
        @project = @build.project
        recipients = add_recipients recipients
        unless recipients.blank?
          mail(:to => recipients, :subject => "'#{@build.display_name}' in '#{@project.name}' still fails") do |format|
            format.text { render "mailer/build_still_fails" }
          end
        end
      end

      def build_fixed(build, recipients)
        @build = build
        @project = @build.project
        recipients = add_recipients recipients
        unless recipients.blank?
          mail(:to => recipients, :subject => "'#{@build.display_name}' in '#{@project.name}' fixed") do |format|
            format.text { render "mailer/build_fixed" }
          end
        end
      end

      private
        def add_recipients(arg)
          if arg.blank?
            "#{@build.author} <#{@build.email}>"
          else
            arg.concat ", #{@build.author} <#{@build.email}>"
          end
        end
    end
  end
end
