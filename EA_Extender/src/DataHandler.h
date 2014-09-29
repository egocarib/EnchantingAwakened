#include "skse/GameData.h"
#include "skse/GameRTTI.h"
#include <vector>
#include <map>

class TESForm;
class BGSListForm;
class EnchantmentItem;



class EnchantmentDataHandler //Exposes list of all loaded enchantment forms
{
private:
	EnchantmentDataHandler() {}

public:
	template <class Visitor>
	static void Visit(Visitor* visitor)
	{
		DataHandler* data = DataHandler::GetSingleton();
		bool bContinue = true;
		for(UInt32 i = 0; (i < data->enchantments.count) && bContinue; i++)
		{
			EnchantmentItem* pEnch = NULL;
			data->enchantments.GetNthItem(i, pEnch);
			if (pEnch)
				bContinue = visitor->Accept(pEnch);
		}
	}
};


class BaseEnchantmentUseResearcher
{
private:
	typedef std::map<EnchantmentItem*, std::vector<EnchantmentItem*>> EnchantmentTreeT;

	EnchantmentTreeT	fillTree;

	BaseEnchantmentUseResearcher() : fillTree() { EnchantmentDataHandler::Visit(this); }

public:
	bool Accept(EnchantmentItem* e)
	{
		if (e)
		{
			EnchantmentItem* eBase = (e->data.baseEnchantment) ? (e->data.baseEnchantment) : (e);
			fillTree[eBase].push_back(e);
		}
		return true;
	}

	void AddChildrenToList(EnchantmentItem* base, BGSListForm* list)
	{
		if (base)
			for (UInt32 i = 0; i < fillTree[base].size(); i++)
				CALL_MEMBER_FN(list, AddFormToList)(fillTree[base][i]);
	}

	static BaseEnchantmentUseResearcher* GetSingleton()
	{
		static BaseEnchantmentUseResearcher baseEnchantmentUseInfo;
		return &baseEnchantmentUseInfo;
	}
};


class DerivedEnchantmentListProcessor : public BGSListForm::Visitor
{
private:
	BaseEnchantmentUseResearcher* research;
	BGSListForm* formlist;

public:
	DerivedEnchantmentListProcessor(BGSListForm* arg1)
		: research(BaseEnchantmentUseResearcher::GetSingleton())
		, formlist(arg1) {}

	virtual bool Accept(TESForm * form)
	{
		EnchantmentItem* thisBase = DYNAMIC_CAST(form, TESForm, EnchantmentItem);
		research->AddChildrenToList(thisBase, formlist);
		return false;
	};
};