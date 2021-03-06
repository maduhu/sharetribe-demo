class TestimonialGivenJob < Struct.new(:testimonial_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    testimonial = Testimonial.find(testimonial_id)
    testimonial.participation.update_attribute(:is_read, true)
    testimonial.notify_receiver(community)
    received = testimonial.receiver.received_testimonials.positive
  end

end
