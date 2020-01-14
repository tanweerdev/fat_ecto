defmodule FatEcto.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: FatEcto.Repo

  def bed_factory do
    %FatEcto.FatBed{
      name: "John",
      purpose: "purpose",
      description: "descriptive",
      is_active: false
    }
  end

  def doctor_factory do
    {:ok, start_date, _} = DateTime.from_iso8601("2017-01-01T00:00:00Z")
    {:ok, end_date, _} = DateTime.from_iso8601("2017-01-02T00:00:00Z")

    %FatEcto.FatDoctor{
      name: "John",
      designation: "Surgeon",
      phone: "12345",
      address: "main bulevard",
      email: "test@test.com",
      experience_years: 7,
      rating: 9,
      start_date: start_date,
      end_date: end_date
    }
  end

  def doctor_patient_factory do
    %FatEcto.FatDoctorPatient{}
  end

  def hospital_doctor_factory do
    %FatEcto.FatHospitalDoctor{}
  end

  def hospital_factory do
    %FatEcto.FatHospital{
      name: "st marry",
      location: "main bullevard",
      phone: "12345",
      address: "123 street",
      total_staff: 3,
      rating: 5
    }
  end

  def patient_factory do
    %FatEcto.FatPatient{
      name: "st marry",
      location: "main bullevard",
      phone: "12345",
      address: "123 street",
      prescription: "doses",
      symptoms: "fever",
      date_of_birth: "1-4-1994",
      appointments_count: 4
    }
  end

  def room_factory do
    %FatEcto.FatRoom{
      name: "room 1",
      purpose: "serious patients",
      description: "sensitive",
      is_active: true,
      floor: 3
    }
  end
end
