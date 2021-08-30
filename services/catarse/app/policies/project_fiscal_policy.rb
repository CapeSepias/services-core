# frozen_string_literal: true

class ProjectFiscalPolicy < ApplicationPolicy
  def debit_note?
    done_by_owner_or_admin?
  end

  def inform?
    done_by_owner_or_admin?
  end
end
