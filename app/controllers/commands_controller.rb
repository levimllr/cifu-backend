class CommandsController < ApplicationController
  def create

    sheet_link = "https://docs.google.com/spreadsheets/d/1FNN6pRAMpxZPdT4reFGSqo_2EPYo6W-X9wLFmuWbWYU/edit?usp=sharing"

    if params["command"] == "/bulletin"
      channel_id = params["channel_id"]
      command = params["text"].split(" ").first
      option = params["text"].split(" ").second

      case command
      when "intro"
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":u55b6: Hello world!\n:id: This channel's ID is *#{channel_id}*.\n:hash:To set up your mass message schedule, make a copy of this Google sheet:\n#{sheet_link}"
        )
      when "channel"
        channel_name = params["channel_name"]
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":id: #{channel_name}'s channel ID is *#{channel_id}*."
        )
      when "sheet"
        channel_name = params["channel_name"]
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":hash: To set up your mass message schedule, make a copy of this Google sheet:\n#{sheet_link}"
        )
      when "schedule"
        channel_name = params["channel_name"]
        
        scheduled_messages = bot_slack_client.chat_scheduledMessages_list(
          channel: channel_id,
        )[:scheduled_messages].sort_by{ |msg| msg.post_at }

        schedule_string_prefix = [
          ":u6307: There are *#{scheduled_messages.length} messages* scheduled for channel *#{channel_id}*.",
          ":u6708: Messages are scheduled between *#{format_unix_to_normal_time(scheduled_messages.first.post_at)}* and *#{format_unix_to_normal_time(scheduled_messages.last.post_at)}*:",
          "```",
          " # |    Local date, time    | Message ID",
          "---|------------------------|-----------"
        ]

        schedule_string = scheduled_messages.map.with_index do |msg, idx| 
          " #{idx + 1} | #{Time.at(msg.post_at).strftime("%Y-%m-%d %I:%M:%S %p")} | #{msg.id}"
        end

        full_schedule_string = schedule_string_prefix.push(schedule_string).push("```").join("\n")

        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: full_schedule_string
        )
      else
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":sos: Invalid command! Type `/bulletin` or click on my icon see options." 
        )
      end 
    end
  end
end