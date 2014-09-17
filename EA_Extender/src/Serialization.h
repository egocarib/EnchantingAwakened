#pragma once

struct SKSESerializationInterface;

const UInt32 kSerializationDataVersion = 1;

namespace EASerialization
{
	void Serialization_Revert(SKSESerializationInterface* intfc);
	void Serialization_Save(SKSESerializationInterface* intfc);
	void Serialization_Load(SKSESerializationInterface* intfc);
};